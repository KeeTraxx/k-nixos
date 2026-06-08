#!/usr/bin/env bash
# Installs NixOS on a remote machine using nixos-anywhere.
# Run this from your dev machine. The target only needs to be booted from
# a NixOS live ISO and reachable via SSH as root.
#
# Usage: scripts/install.sh <hostname> <target-ip>
# Example: scripts/install.sh myhost 192.168.1.42
#
# Prerequisites:
#   - scripts/add-host.sh <hostname> <disk> was run and pushed
#   - nix flake update was run (flake.lock exists)
#   - Target is reachable: ssh root@<target-ip>
set -euo pipefail

HOSTNAME="${1:?Usage: install.sh <hostname> <target-ip>}"
TARGET="${2:?Usage: install.sh <hostname> <target-ip>}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

# ── Preflight ─────────────────────────────────────────────────────────────────
[[ -f "$REPO_ROOT/hosts/$HOSTNAME/default.nix" ]] || {
  echo "Error: host '$HOSTNAME' not found. Run scripts/add-host.sh $HOSTNAME <disk> first." >&2
  exit 1
}
[[ -f "$REPO_ROOT/flake.lock" ]] || {
  echo "Error: flake.lock missing. Run 'nix flake update' in $REPO_ROOT first." >&2
  exit 1
}

# ── LUKS passphrase ───────────────────────────────────────────────────────────
echo "Enter the LUKS passphrase for disk encryption."
echo "You will type this on every boot."
echo ""
read -s -r -p "Passphrase: " LUKS_PASS; echo
read -s -r -p "Confirm:    " LUKS_PASS2; echo
[[ "$LUKS_PASS" == "$LUKS_PASS2" ]] || { echo "Passphrases do not match." >&2; exit 1; }
echo ""

# ── Install ───────────────────────────────────────────────────────────────────
echo "Installing NixOS on root@$TARGET as '$HOSTNAME' ..."
echo "Hardware configuration will be saved to hosts/$HOSTNAME/hardware-configuration.nix"
echo ""

nix run github:nix-community/nixos-anywhere -- \
  --generate-hardware-config nixos-generate-config \
    "$REPO_ROOT/hosts/$HOSTNAME/hardware-configuration.nix" \
  --disk-encryption-keys /tmp/luks.key <(printf '%s' "$LUKS_PASS") \
  --flake "$REPO_ROOT#$HOSTNAME" \
  root@"$TARGET"

# ── Post-install ──────────────────────────────────────────────────────────────
echo ""
echo "================================================================"
echo " Done! The machine is rebooting."
echo "================================================================"
echo ""
echo "hardware-configuration.nix has been captured locally."
echo "Commit it so future reinstalls skip the ISO entirely:"
echo ""
echo "  cd $REPO_ROOT"
echo "  git add hosts/$HOSTNAME/hardware-configuration.nix"
echo "  git commit -m 'Add hardware configuration for $HOSTNAME'"
echo "  git push"
echo ""
echo "Future reinstalls:"
echo "  nix run github:nix-community/nixos-anywhere -- \\"
echo "    --flake github:keetraxx/k-nixos#$HOSTNAME \\"
echo "    root@<new-ip>"
