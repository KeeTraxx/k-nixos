{
  pkgs,
  osConfig ? null,
  nixGLWrapper ? null,
  ...
}:
let
  nixGLWrap =
    pkg:
    if osConfig ? system.stateVersion then
      pkg
    else
      pkgs.runCommand "${pkg.name}-nixgl" { nativeBuildInputs = [ pkgs.makeWrapper ]; } ''
        mkdir -p $out/bin
        nixgl_bin=$(echo ${nixGLWrapper}/bin/*)
        for bin in ${pkg}/bin/*; do
          makeWrapper "$nixgl_bin" $out/bin/$(basename $bin) \
            --add-flags "$bin"
        done
      '';
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
