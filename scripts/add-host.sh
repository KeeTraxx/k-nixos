#!/usr/bin/env bash
# Scaffolds a new host configuration in the repo.
# Run this on your dev machine BEFORE running install.sh.
#
# Usage: scripts/add-host.sh <hostname> <disk>
# Example: scripts/add-host.sh myhost /dev/nvme0n1
#          scripts/add-host.sh myhost /dev/sda
set -euo pipefail

HOSTNAME="${1:?Usage: add-host.sh <hostname> <disk>}"
DISK="${2:?Usage: add-host.sh <hostname> <disk>}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
HOST_DIR="$REPO_ROOT/hosts/$HOSTNAME"

if [[ -d "$HOST_DIR" ]]; then
  echo "Error: host '$HOSTNAME' already exists at $HOST_DIR" >&2
  exit 1
fi

mkdir -p "$HOST_DIR"

cat > "$HOST_DIR/disk.nix" << EOF
{ ... }: {
  disko.devices = {
    disk.main = {
      type = "disk";
      device = "$DISK";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "512M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };
          luks = {
            size = "100%";
            content = {
              type = "luks";
              name = "cryptroot";
              # install.sh uploads the passphrase here via --disk-encryption-keys
              passwordFile = "/tmp/luks.key";
              settings.allowDiscards = true;
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
    };
  };
}
EOF

cat > "$HOST_DIR/default.nix" << EOF
{ pkgs, ... }: {
  imports = [
    ./disk.nix
    ./hardware-configuration.nix
    ../../modules/common.nix
    ../../users/kt/default.nix
  ];

  nixpkgs.hostPlatform.system = "x86_64-linux";

  networking.hostName = "$HOSTNAME";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;

  system.stateVersion = "24.11";
}
EOF

# Stub so the flake evaluates before install generates the real one.
# install.sh replaces this via --generate-hardware-config.
cat > "$HOST_DIR/hardware-configuration.nix" << 'EOF'
{ modulesPath, ... }: {
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];
}
EOF

echo "Host '$HOSTNAME' scaffolded at $HOST_DIR"
echo ""
echo "Next steps:"
echo "  1. Review/edit $HOST_DIR/default.nix (users, desktop, etc.)"
echo "  2. Commit and push:"
echo "       git add hosts/$HOSTNAME"
echo "       git commit -m 'Add host $HOSTNAME'"
echo "       git push"
echo "  3. Boot the target machine from a NixOS ISO, then from this machine:"
echo "       scripts/install.sh $HOSTNAME <target-ip>"
