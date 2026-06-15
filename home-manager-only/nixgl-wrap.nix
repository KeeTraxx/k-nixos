{ pkgs, lib, osConfig ? null, nixGLWrapper ? null, config, ... }:
{
  options.nixGLWrap = lib.mkOption {
    type = lib.types.functionTo lib.types.package;
    readOnly = true;
  };

  config.nixGLWrap =
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
        for dir in share lib etc; do
          if [ -d "${pkg}/$dir" ]; then
            ln -s "${pkg}/$dir" "$out/$dir"
          fi
        done
      '';
}
