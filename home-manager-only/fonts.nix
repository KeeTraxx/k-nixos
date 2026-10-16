# NixOS hosts get fonts from modules/required/fonts.nix; standalone
# home-manager has no system config, so install the same list per user.
{ pkgs, ... }: {
  home.packages = import ../modules/required/font-packages.nix pkgs;
}
