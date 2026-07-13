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
        for dir in lib etc; do
          if [ -d "${pkg}/$dir" ]; then
            ln -s "${pkg}/$dir" "$out/$dir"
          fi
        done
        if [ -d "${pkg}/share" ]; then
          mkdir -p $out/share
          for entry in ${pkg}/share/*; do
            if [ "$(basename $entry)" = applications ]; then
              # rewrite desktop entries to point at the wrapped binaries
              mkdir $out/share/applications
              for f in $entry/*; do
                sed "s|${pkg}/bin|$out/bin|g" "$f" > "$out/share/applications/$(basename $f)"
              done
            else
              ln -s "$entry" $out/share/
            fi
          done
        fi
      '';
}
