#!/usr/bin/env bash
# Deploy a configuration update to a remote NixOS host.
# SSHes into the target and runs nixos-rebuild switch from the GitHub repo.
# Requires the local repo to be clean and pushed.
#
# Usage: scripts/update.sh [--port PORT] [--user USER] <hostname> <target-ip>
# Example: scripts/update.sh myhost 192.168.1.42
#          scripts/update.sh --port 2222 myhost 192.168.1.42
#          scripts/update.sh --user kt myhost 192.168.1.42
set -euo pipefail

SSH_PORT=""
SSH_USER="kt"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --port|-p) SSH_PORT="$2"; shift 2 ;;
    --user|-u) SSH_USER="$2"; shift 2 ;;
    *) break ;;
  esac
done

HOSTNAME="${1:?Usage: update.sh [--port PORT] [--user USER] <hostname> <target-ip>}"
TARGET="${2:?Usage: update.sh [--port PORT] [--user USER] <hostname> <target-ip>}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

# ── Preflight ─────────────────────────────────────────────────────────────────
[[ -f "$REPO_ROOT/hosts/$HOSTNAME/nixos-base.nix" ]] || {
  echo "Error: host '$HOSTNAME' not found in $REPO_ROOT/hosts/" >&2
  exit 1
}

if ! git -C "$REPO_ROOT" diff --quiet || ! git -C "$REPO_ROOT" diff --cached --quiet; then
  echo "Error: repo has uncommitted changes — commit and push first." >&2
  exit 1
fi

# ── Update ────────────────────────────────────────────────────────────────────
SSH_OPTS="-t -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
[[ -n "$SSH_PORT" ]] && SSH_OPTS="$SSH_OPTS -p $SSH_PORT"

echo "Updating '$HOSTNAME' on $TARGET ..."
# shellcheck disable=SC2086
ssh $SSH_OPTS "$SSH_USER"@"$TARGET" k-nixos-update
