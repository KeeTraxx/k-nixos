{ config, pkgs, lib, ... }:
{
  programs.firefox.enable = true;
  programs.chromium.enable = true;
  services.printing.enable = true;
  hardware.bluetooth.enable = true;

  services = {
    desktopManager.plasma6.enable = true;

    displayManager.sddm.enable = true;

    displayManager.sddm.wayland.enable = true;
  };


  environment.systemPackages = with pkgs;
    [
      # KDE
      kdePackages.discover # Optional: Install if you use Flatpak or fwupd firmware update sevice
      kdePackages.kcalc # Calculator
      kdePackages.kcharselect # Tool to select and copy special characters from all installed fonts
      kdePackages.kclock # Clock app
      kdePackages.kcolorchooser # A small utility to select a color
      kdePackages.kolourpaint # Easy-to-use paint program
      kdePackages.ksystemlog # KDE SystemLog Application
      kdePackages.sddm-kcm # Configuration module for SDDM
      kdiff3 # Compares and merges 2 or 3 files or directories
      kdePackages.isoimagewriter # Optional: Program to write hybrid ISO files onto USB disks
      kdePackages.partitionmanager # Optional: Manage the disk devices, partitions and file systems on your computer
      # Non-KDE graphical packages
      vlc # Cross-platform media player and streaming server
      wayland-utils # Wayland utilities
      wl-clipboard # Command-line copy/paste utilities for Wayland
      xclip # Tool to access the X clipboard from a console application
      vscode
      krita
      jetbrains.idea-ultimate
      texstudio
      aria2
      audacity
      blender
      brave
      foot
      brightnessctl
      chezmoi
      chromium
      epson-escpr2
      drawio
      mcomix
      obs-studio
      libreoffice-qt6-fresh
      prusa-slicer
      kdePackages.skanlite
      kdePackages.skanpage
      displaylink
    ];

    # --- THIS IS THE CRUCIAL PART FOR ENABLING THE SERVICE ---
    systemd.services.displaylink-server = {
      enable = true;
      # Ensure it starts after udev has done its work
      requires = [ "systemd-udevd.service" ];
      after = [ "systemd-udevd.service" ];
      wantedBy = [ "multi-user.target" ]; # Start at boot
      # *** THIS IS THE CRITICAL 'serviceConfig' BLOCK ***
      serviceConfig = {
        Type = "simple"; # Or "forking" if it forks (simple is common for daemons)
        # The ExecStart path points to the DisplayLinkManager binary provided by the package
        ExecStart = "${pkgs.displaylink}/bin/DisplayLinkManager";
        # User and Group to run the service as (root is common for this type of daemon)
        User = "root";
        Group = "root";
        # Environment variables that the service itself might need
        # Environment = [ "DISPLAY=:0" ]; # Might be needed in some cases, but generally not for this
        Restart = "on-failure";
        RestartSec = 5; # Wait 5 seconds before restarting
      };
    };

   i18n.inputMethod = {
    enable = true;
     type = "fcitx5";
     fcitx5.addons = with pkgs; [
       kdePackages.fcitx5-qt
       fcitx5-mozc
       fcitx5-gtk
       fcitx5-nord
     ];
   };

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
  };

  fonts.packages = []  ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);

}