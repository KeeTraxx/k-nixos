{ pkgs, ... }: {
  imports = [
    ../../modules/nixgl-wrap.nix
    ./plasma-manager-config.nix
    ./git.nix
    ./fish.nix
    ./rust.nix
    ../../modules/swisstopo/swisstopo.nix
    ./foot.nix
    ./desktop.nix
    ./cli-tools.nix
    ./zed.nix
  ];
  home.stateVersion = "26.05";

  programs.less.enable = true;
  programs.htop.enable = true;
  programs.fish.enable = true;

}
