#!/usr/bin/env bash
# Deploy a configuration update to a remote NixOS host.
# SSHes into the target and runs nixos-rebuild switch from the GitHub repo.
# Requires the local repo to be clean and pushed.
#
# Usage: scripts/update.sh [--port PORT] <hostname> <target-ip>
# Example: scripts/update.sh myhost 192.168.1.42
#          scripts/update.sh --port 2222 myhost 192.168.1.42
set -euo pipefail

SSH_PORT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --port|-p) SSH_PORT="$2"; shift 2 ;;
    *) break ;;
  esac
done

HOSTNAME="${1:?Usage: update.sh [--port PORT] <hostname> <target-ip>}"
TARGET="${2:?Usage: update.sh [--port PORT] <hostname> <target-ip>}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

# ── Preflight ─────────────────────────────────────────────────────────────────
[[ -f "$REPO_ROOT/hosts/$HOSTNAME/default.nix" ]] || {
  echo "Error: host '$HOSTNAME' not found in $REPO_ROOT/hosts/" >&2
  exit 1
}

if ! git -C "$REPO_ROOT" diff --quiet || ! git -C "$REPO_ROOT" diff --cached --quiet; then
  echo "Error: repo has uncommitted changes — commit and push first." >&2
  exit 1
fi

REMOTE_URL=$(git -C "$REPO_ROOT" remote get-url origin)
FLAKE_REF="${REMOTE_URL/git@github.com:/github:}"
FLAKE_REF="${FLAKE_REF%.git}"

# ── Update ────────────────────────────────────────────────────────────────────
SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
[[ -n "$SSH_PORT" ]] && SSH_OPTS="$SSH_OPTS -p $SSH_PORT"

echo "Updating '$HOSTNAME' on $TARGET from $FLAKE_REF ..."
# shellcheck disable=SC2086
ssh $SSH_OPTS root@"$TARGET" \
  "nixos-rebuild switch --flake '${FLAKE_REF}#${HOSTNAME}'"
