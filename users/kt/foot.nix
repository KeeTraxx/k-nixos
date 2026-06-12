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
  programs.foot = {
    enable = true;
    package = nixGLWrap pkgs.foot;
    settings = {
      main = {
        term = "kitty";
        initial-window-size-chars = "128x40";
        font = "Hack Nerd Font:size=14";
      };
    };
  };
}
