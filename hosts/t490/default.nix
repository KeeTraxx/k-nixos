{ pkgs, ... }: {
  imports = [
    ./disk.nix
    ./hardware-configuration.nix
    ../../modules/common.nix
    ../../users/kt/default.nix
  ];

  nixpkgs.hostPlatform.system = "x86_64-linux";

  networking.hostName = "t490";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;

  system.stateVersion = "26.05";
}
