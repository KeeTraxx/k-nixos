{ pkgs, ... }: {
  imports = [
    ../../home-manager-only/nixgl-wrap.nix
    ./plasma-manager-config.nix
    ./git.nix
    ./fish.nix
    ./foot.nix
    ./desktop.nix
  ];
  fonts.fontconfig.enable = true;

  home.stateVersion = "26.05";

  programs.less.enable = true;
  programs.htop.enable = true;
  programs.fish.enable = true;

}
