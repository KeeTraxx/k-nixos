{
  pkgs,
  lib,
  nixGLWrap,
  ...
}:
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
