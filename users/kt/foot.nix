{ pkgs, lib, nixGLWrap ? null, ... }:
{
  programs.foot = {
    enable = true;
    package = if nixGLWrap != null then nixGLWrap pkgs.foot else pkgs.foot;
    settings = {
      main = {
        term = "kitty";
        initial-window-size-chars = "128x40";
        font = "Hack Nerd Font:size=14";
      };
    };
  };
}
