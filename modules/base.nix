{ config, pkgs, ... }:

{

  system.stateVersion = "25.05"; # Did you read the comment?
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

  services.envfs.enable = true;

  # Automatic garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";  # Keep generations from last 30 days
  };
}