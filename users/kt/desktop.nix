{
  pkgs,
  osConfig ? null,
  config,
  ...
}:
let
  nixGLWrap = pkg: if osConfig ? system.stateVersion then pkg else config.lib.nixGL.wrap pkg;
in
{
  home.packages = with pkgs; [
    (nixGLWrap mesa-demos) # glxgears
    (nixGLWrap vulkan-tools) # vkcube vkgears
    (nixGLWrap godot)
    (nixGLWrap logseq)
    (nixGLWrap drawio)
    (nixGLWrap unstable.zed-editor)
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.hack
    (nixGLWrap keepassxc)
    (nixGLWrap jetbrains.idea-oss)
  ];
  home.shellAliases = {
    zed = "zeditor";
  };
}
