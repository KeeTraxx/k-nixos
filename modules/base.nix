{ config, pkgs, ... }:

{
  # never change this once you set it for the first time
  system.stateVersion = "25.05";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Configure console keymap
  console.keyMap = "sg";



  # allow unfree packages (steam, nvidia, vscode, etc.)
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  time.timeZone = "Europe/Zurich";

  programs.fish.enable = true;
  programs.wireshark.enable = true;
  programs.light.enable = true;
  programs.less.enable = true;
  programs.iftop.enable = true;
  programs.htop.enable = true;
  programs.git.enable = true;
  programs.git.lfs.enable = true;

  programs.command-not-found.enable = true;
  networking.networkmanager.enable = true;
  networking.networkmanager.plugins = with pkgs; [
    networkmanager-openvpn
  ];

  services.openssh.enable = true;

  environment.systemPackages = with pkgs;
  [
    awscli2
    bat
    flatpak
    mc
    minio-client
    yt-dlp
  ];

  virtualisation.docker.enable = true;
  virtualisation.docker.storageDriver = "btrfs";

  # makes all current binaries available under /bin and /usr/bin
  # useful for some scripts that use #!/bin/sh or similar instead of #!/usr/bin/env sh
  services.envfs.enable = true;

  # Automatic garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";  # Keep generations from last 30 days
  };
}