{ pkgs, config, ... }:
{
  home.packages = with pkgs; [
    (config.nixGLWrap godot)
    (config.nixGLWrap unstable.zed-editor)
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.hack
  ];
}
