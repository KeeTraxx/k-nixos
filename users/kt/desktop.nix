{
  pkgs,
  lib,
  nixGLWrap ? null,
  ...
}:
let
  wrap = pkg: if nixGLWrap != null then nixGLWrap pkg else pkg;
in
{
  home.packages = with pkgs; [
    (wrap mesa-demos) # glxgears
    (wrap vulkan-tools) # vkcube vkgears
    (wrap godot)
    (wrap logseq)
    (wrap drawio)
    (wrap zed-editor)
  ];
}
