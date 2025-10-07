{ config, pkgs, ... }:

{
  # Import the local hardware config
  imports = [
    /etc/nixos/hardware-configuration.nix
    ../../modules/boot.nix
    ../../modules/sound.nix
    ../../modules/users.nix
    ../../modules/base.nix
    ../../modules/desktop.nix
    ../../modules/game.nix
  ];

}
