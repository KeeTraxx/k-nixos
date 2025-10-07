#!/bin/sh


# List all available disks
echo "Available disks:"
lsblk -d -o NAME,SIZE,MODEL | grep -v "loop"

# Ask the user to select a disk
read -p "Enter the disk name (e.g., sda, nvme0n1): " disk

# Verify that the disk exists
if lsblk -d | grep -q "^$disk"; then
    echo "You selected: /dev/$disk"
else
    echo "Error: Disk /dev/$disk not found."
    exit 1
fi

# WARNING: destructive
parted -s /dev/$disk mklabel gpt
parted -s /dev/$disk mkpart "EFI" fat32 1MiB 2048MiB
parted -s /dev/$disk set 1 esp on
parted -s /dev/$disk mkpart "linuxswap" linux-swap 2048MiB 8192MiB
parted -s /dev/$disk mkpart "main" btrfs 8192MiB 100%

# Determine partition naming scheme
if echo "$disk" | grep -q "nvme\|mmcblk"; then
    PART_PREFIX="${disk}p"
else
    PART_PREFIX="$disk"
fi

EFI_PARTITION="${PART_PREFIX}1"
SWAP_PARTITION="${PART_PREFIX}2"
MAIN_PARTITION="${PART_PREFIX}3"

mkfs.fat -F32 /dev/$EFI_PARTITION
mkswap /dev/$SWAP_PARTITION
swapon /dev/$SWAP_PARTITION
mkfs.btrfs /dev/$MAIN_PARTITION

mount /dev/$MAIN_PARTITION /mnt
mkdir /mnt/boot
mount /dev/$EFI_PARTITION /mnt/boot

nixos-generate-config --root /mnt

# hack to make nixos-install work
ln -s /mnt/etc/nixos/hardware-configuration.nix /etc/nixos/hardware-configuration.nix

echo "START INSTALL: nixos-install --flake .#<HOSTNAME> --impure"
