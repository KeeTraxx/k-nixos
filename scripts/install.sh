#!/usr/bin/env bash
# Full NixOS installer via nixos-anywhere over SSH.
# Run from your dev machine. Target only needs to be a NixOS live ISO with SSH running.
#
# Usage: scripts/install.sh [--port PORT] <hostname> [disk] <target-ip>
# Example: scripts/install.sh myhost 192.168.1.42
#          scripts/install.sh myhost /dev/nvme0n1 192.168.1.42
#          scripts/install.sh --port 2222 myhost 192.168.1.42
#
# What this does:
#   1. Scaffolds hosts/<hostname>/ in this repo if it doesn't exist yet
#   2. Auto-detects the target disk over SSH if not specified
#   3. Prompts for a LUKS passphrase
#   4. Runs nixos-anywhere: partitions disk, sets up LUKS, installs NixOS
#   5. Captures hardware-configuration.nix locally for committing
set -euo pipefail

SSH_PORT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --port|-p) SSH_PORT="$2"; shift 2 ;;
    *) break ;;
  esac
done

HOSTNAME="${1:?Usage: install.sh [--port PORT] <hostname> [disk] <target-ip>}"

# Disk is optional: if the next arg starts with /dev/ treat it as the disk,
# otherwise skip it and auto-detect later.
if [[ "${2:-}" == /dev/* ]]; then
  DISK="$2"
  TARGET="${3:?Usage: install.sh [--port PORT] <hostname> [disk] <target-ip>}"
else
  DISK=""
  TARGET="${2:?Usage: install.sh [--port PORT] <hostname> [disk] <target-ip>}"
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

# Helper: run a command on the target via SSH
ssh_target() {
  local ssh_args=(
    -o StrictHostKeyChecking=no
    -o UserKnownHostsFile=/dev/null
    -o ConnectTimeout=10
  )
  [[ -n "$SSH_PORT" ]] && ssh_args+=(-p "$SSH_PORT")
  ssh "${ssh_args[@]}" root@"$TARGET" "$@"
}

# ── Auto-detect disk ──────────────────────────────────────────────────────────
if [[ -z "$DISK" ]]; then
  echo "No disk specified — detecting first disk on $TARGET ..."
  DISK=$(ssh_target "lsblk -dpno NAME,TYPE | awk '\$2==\"disk\"{print \$1; exit}'")
  [[ -n "$DISK" ]] || { echo "Error: could not detect a disk on $TARGET" >&2; exit 1; }
  echo "Using disk: $DISK"
  echo ""
fi

# ── Scaffold host config if needed ────────────────────────────────────────────
if [[ ! -d "$REPO_ROOT/hosts/$HOSTNAME" ]]; then
  echo "No config found for '$HOSTNAME' — scaffolding from template..."
  echo ""
  "$SCRIPT_DIR/add-host.sh" "$HOSTNAME" "$DISK"
  echo ""
  echo "You can edit hosts/$HOSTNAME/default.nix before continuing."
  read -r -p "Press Enter to continue with install, or Ctrl-C to abort and edit first: "
  echo ""
fi

# Nix requires all flake files to be git-tracked (staged or committed).
git -C "$REPO_ROOT" add --intent-to-add hosts/"$HOSTNAME" 2>/dev/null || true

# ── Preflight ─────────────────────────────────────────────────────────────────
if [[ ! -f "$REPO_ROOT/flake.lock" ]]; then
  echo "No flake.lock found — running 'nix flake update' ..."
  nix flake update --flake "$REPO_ROOT"
  echo ""
fi

# Temp files — cleaned up on exit regardless of success or failure
LUKS_KEY_FILE=$(mktemp)
EXTRA_FILES=$(mktemp -d)
trap 'rm -f "$LUKS_KEY_FILE"; rm -rf "$EXTRA_FILES"' EXIT

# Helper: hash a password with SHA-512 crypt (openssl is available everywhere)
hash_password() { printf '%s' "$1" | openssl passwd -6 -stdin; }

# Prompt helper: read a password twice and confirm
read_password() {
  local label="$1" pass1 pass2
  while true; do
    read -s -r -p "$label: " pass1; echo >&2
    read -s -r -p "Confirm:  " pass2; echo >&2
    if [[ "$pass1" == "$pass2" ]]; then
      printf '%s' "$pass1"
      return
    fi
    echo "Passwords do not match, try again." >&2
  done
}

# ── LUKS passphrase ───────────────────────────────────────────────────────────
echo "--- Disk encryption ---"
echo "This passphrase unlocks the disk on every boot."
echo ""
LUKS_PASS=$(read_password "LUKS passphrase")
printf '%s' "$LUKS_PASS" > "$LUKS_KEY_FILE"
echo ""

# ── User passwords ────────────────────────────────────────────────────────────
# Passwords are hashed locally and uploaded via --extra-files.
# They land at /etc/secrets/users/<name> and are never stored in the Nix store.
mkdir -p "$EXTRA_FILES/etc/secrets/users"
chmod 700 "$EXTRA_FILES/etc/secrets" "$EXTRA_FILES/etc/secrets/users"

echo "--- Initial passwords ---"
echo "These are for local/console login. SSH uses keys only."
echo ""

# Root
ROOT_PASS=$(read_password "root password")
hash_password "$ROOT_PASS" > "$EXTRA_FILES/etc/secrets/users/root"
echo ""

# One entry per directory under users/
for USER_DIR in "$REPO_ROOT/users"/*/; do
  USER=$(basename "$USER_DIR")
  USER_PASS=$(read_password "password for $USER")
  hash_password "$USER_PASS" > "$EXTRA_FILES/etc/secrets/users/$USER"
  echo ""
done

chmod 400 "$EXTRA_FILES/etc/secrets/users/"*

# ── Install ───────────────────────────────────────────────────────────────────
echo "Installing NixOS on root@$TARGET as '$HOSTNAME' ..."
echo ""

NIXOS_ANYWHERE_ARGS=(
  --generate-hardware-config nixos-generate-config
    "$REPO_ROOT/hosts/$HOSTNAME/hardware-configuration.nix"
  --disk-encryption-keys /tmp/luks.key "$LUKS_KEY_FILE"
  --extra-files "$EXTRA_FILES"
  --flake "$REPO_ROOT#$HOSTNAME"
)

[[ -n "$SSH_PORT" ]] && NIXOS_ANYWHERE_ARGS+=(--ssh-port "$SSH_PORT")

NIXOS_ANYWHERE_ARGS+=(root@"$TARGET")

nix run github:nix-community/nixos-anywhere -- "${NIXOS_ANYWHERE_ARGS[@]}"

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
echo "================================================================"
echo " Done! The machine is rebooting."
echo "================================================================"
echo ""
echo "Commit the generated config to enable future installs without a live ISO:"
echo ""
echo "  cd $REPO_ROOT"
echo "  git add hosts/$HOSTNAME"
echo "  git commit -m 'Add $HOSTNAME'"
echo "  git push"
echo ""
echo "Future reinstalls (no ISO needed):"
echo "  nix run github:nix-community/nixos-anywhere -- \\"
echo "    --flake github:keetraxx/k-nixos#$HOSTNAME \\"
echo "    [--ssh-port PORT] \\"
echo "    root@<ip>"
