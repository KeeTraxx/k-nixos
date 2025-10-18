{ config, pkgs, nixpkgs-unstable, ... }:

{
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = nixpkgs-unstable.linuxPackages_latest;

}
