{ pkgs, ... }: {
  imports = [
    ./disk.nix
    ./hardware-configuration.nix
    ../../modules/required/common.nix
    ../../modules/required/fonts.nix
    ../../modules/required/k-nixos-update.nix
    ../../modules/required/docker.nix
    ../../modules/optional/flatpak.nix
    ../../modules/optional/kde.nix
    ../../modules/optional/niri.nix
    ../../modules/optional/desktop-apps.nix
    ../../users/ft/main-nixos.nix
    ../../users/kt/main-nixos.nix
  ];

  nixpkgs.hostPlatform.system = "x86_64-linux";

  networking.hostName = "t490";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;

  system.stateVersion = "26.05";
}
