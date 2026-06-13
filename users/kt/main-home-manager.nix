{ pkgs, ... }: {
  imports = [
    ../../modules/manual-only/nixgl-wrap.nix
    ./plasma-manager-config.nix
    ./git.nix
    ./fish.nix
    ./rust.nix
    ../../modules/manual-only/swisstopo/swisstopo.nix
    ./foot.nix
    ./desktop.nix
    ./cli-tools.nix
    ./zed.nix
  ];
  fonts.fontconfig.enable = true;

  home.stateVersion = "26.05";

  programs.less.enable = true;
  programs.htop.enable = true;
  programs.fish.enable = true;

}
