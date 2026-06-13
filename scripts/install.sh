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
  echo "No disk specified — detecting first disk >= 40 GiB on $TARGET ..."
  # -b: sizes in bytes; filter type==disk and size >= 40 GiB (42949672960 bytes)
  DISK=$(ssh_target "lsblk -bdpno NAME,TYPE,SIZE | awk '\$2==\"disk\" && \$3+0 >= 42949672960 {print \$1; exit}'")
  if [[ -z "$DISK" ]]; then
    echo "Error: no disk >= 40 GiB found on $TARGET. Available disks:" >&2
    ssh_target "lsblk -dpno NAME,SIZE,TYPE" >&2
    exit 1
  fi
  DISK_GIB=$(ssh_target "lsblk -bdpno SIZE '$DISK'" | awk '{printf "%d", $1/1024/1024/1024}')
  echo "Using disk: $DISK (${DISK_GIB} GiB)"
  echo ""
fi

# ── User selection ────────────────────────────────────────────────────────────
ALL_USERS=()
for USER_DIR in "$REPO_ROOT/users"/*/; do
  [[ -d "$USER_DIR" ]] || continue
  ALL_USERS+=("$(basename "$USER_DIR")")
done

echo "--- User selection ---"
echo "Which users should be initialized on this machine?"
for i in "${!ALL_USERS[@]}"; do
  echo "  [$((i+1))] ${ALL_USERS[$i]}"
done
echo ""
read -r -p "Enter names or numbers (space-separated): " USER_INPUT
echo ""

SELECTED_USERS=()
for token in $USER_INPUT; do
  if [[ "$token" =~ ^[0-9]+$ ]]; then
    idx=$((token - 1))
    if (( idx >= 0 && idx < ${#ALL_USERS[@]} )); then
      SELECTED_USERS+=("${ALL_USERS[$idx]}")
    else
      echo "Warning: no user at index $token, skipping" >&2
    fi
  elif [[ -d "$REPO_ROOT/users/$token" ]]; then
    SELECTED_USERS+=("$token")
  else
    echo "Warning: user '$token' not found, skipping" >&2
  fi
done

if [[ ${#SELECTED_USERS[@]} -eq 0 ]]; then
  echo "Error: no valid users selected." >&2
  exit 1
fi

echo "Users for this machine: ${SELECTED_USERS[*]}"
echo ""

# ── Optional module selection ─────────────────────────────────────────────────
ALL_MODULES=()
for MODULE_FILE in "$REPO_ROOT/modules/optional"/*.nix; do
  [[ -f "$MODULE_FILE" ]] || continue
  ALL_MODULES+=("$(basename "$MODULE_FILE" .nix)")
done

echo "--- Optional modules ---"
echo "Which optional modules should be enabled on this machine?"
for i in "${!ALL_MODULES[@]}"; do
  echo "  [$((i+1))] ${ALL_MODULES[$i]}"
done
echo ""
read -r -p "Enter names or numbers (space-separated, Enter to skip): " MODULE_INPUT
echo ""

SELECTED_MODULES=()
for token in $MODULE_INPUT; do
  if [[ "$token" =~ ^[0-9]+$ ]]; then
    idx=$((token - 1))
    if (( idx >= 0 && idx < ${#ALL_MODULES[@]} )); then
      SELECTED_MODULES+=("${ALL_MODULES[$idx]}")
    else
      echo "Warning: no module at index $token, skipping" >&2
    fi
  elif [[ -f "$REPO_ROOT/modules/optional/$token.nix" ]]; then
    SELECTED_MODULES+=("$token")
  else
    echo "Warning: module '$token' not found, skipping" >&2
  fi
done

if [[ ${#SELECTED_MODULES[@]} -gt 0 ]]; then
  echo "Optional modules: ${SELECTED_MODULES[*]}"
else
  echo "No optional modules selected."
fi
echo ""

# ── Scaffold host config if needed ────────────────────────────────────────────
if [[ ! -d "$REPO_ROOT/hosts/$HOSTNAME" ]]; then
  echo "No config found for '$HOSTNAME' — scaffolding from template..."
  echo ""
  "$SCRIPT_DIR/add-host.sh" "$HOSTNAME" "$DISK"

  # Substitute all placeholders in the generated default.nix
  DEFAULT_NIX="$REPO_ROOT/hosts/$HOSTNAME/default.nix"

  REQUIRED_IMPORT_LINES=""
  for MODULE_FILE in "$REPO_ROOT/modules/required"/*.nix; do
    [[ -f "$MODULE_FILE" ]] || continue
    REQUIRED_IMPORT_LINES+="    ../../modules/required/$(basename "$MODULE_FILE")\n"
  done

  OPTIONAL_IMPORT_LINES=""
  for MODULE in "${SELECTED_MODULES[@]}"; do
    OPTIONAL_IMPORT_LINES+="    ../../modules/optional/$MODULE.nix\n"
  done

  USER_IMPORT_LINES=""
  for USER in "${SELECTED_USERS[@]}"; do
    USER_IMPORT_LINES+="    ../../users/$USER/main-nixos.nix\n"
  done

  awk -v req="$REQUIRED_IMPORT_LINES" \
      -v opt="$OPTIONAL_IMPORT_LINES" \
      -v usr="$USER_IMPORT_LINES" \
    '/    @REQUIRED_IMPORTS@/ { printf "%s", req; next }
     /    @OPTIONAL_IMPORTS@/ { if (opt != "") printf "%s", opt; next }
     /    @USER_IMPORTS@/     { printf "%s", usr; next }
     { print }' \
    "$DEFAULT_NIX" > "$DEFAULT_NIX.tmp" && mv "$DEFAULT_NIX.tmp" "$DEFAULT_NIX"

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

# One entry per selected user
for USER in "${SELECTED_USERS[@]}"; do
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
