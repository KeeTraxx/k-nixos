{ pkgs, config, ... }:
{
  home.packages = with pkgs; [
    (config.nixGLWrap godot)
    (config.nixGLWrap unstable.zed-editor)
  ];
}
