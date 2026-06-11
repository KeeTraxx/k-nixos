{
  pkgs,
  config,
  osConfig ? null,
  ...
}:
{
  programs.foot = {
    enable = true;
    # On NixOS, OpenGL is managed by the OS — use foot directly.
    # In standalone home-manager (non-NixOS), nixGLWrap is required for OpenGL.
    package = if osConfig != null then pkgs.foot else config.lib.nixGL.wrap pkgs.foot;
    settings = {
      main = {
        term = "kitty";
        initial-window-size-chars = "128x40";
        font = "Hack Nerd Font:size=14";
      };
    };
  };
}
