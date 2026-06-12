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
    (nixGLWrap zed-editor)
  ];
}
