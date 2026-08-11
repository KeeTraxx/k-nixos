{ pkgs, lib, osConfig ? null, nixGLWrapper ? null, config, ... }:
let
  # NVIDIA's libEGL loads Wayland/X11 window system support as separate "EGL
  # external platform" libraries. nixGL's nvidia package doesn't ship them, and
  # the host copies in /usr/lib are invisible to nix binaries (they resolve
  # against the nix store glibc, which never searches /usr/lib). Without them
  # eglGetPlatformDisplay fails, e.g. ghostty aborts with
  # "failed to make GL context current: Failed to create EGL display".
  # Point the driver at the nixpkgs builds instead; the config dirs replace the
  # host defaults, whose entries we cannot load anyway.
  eglPlatformConfigDirs = lib.concatMapStringsSep ":" (p: "${p}/share/egl/egl_external_platform.d") [
    pkgs.egl-wayland
    pkgs.egl-x11
  ];

  # nixGLNvidia pins __EGL_VENDOR_LIBRARY_FILENAMES to the NVIDIA ICD alone, so
  # libglvnd has no vendor to fall back on when the display is not NVIDIA. On a
  # hybrid laptop the compositor usually drives the Intel/AMD GPU, and
  # eglGetPlatformDisplay then fails outright (EGL_SUCCESS but EGL_NO_DISPLAY)
  # rather than falling back. nixGL appends to this variable when it is already
  # set, so seeding Mesa's ICD here keeps NVIDIA first and Mesa as the fallback.
  mesaVendorConfig = "${lib.getOutput "out" pkgs.mesa}/share/glvnd/egl_vendor.d/50_mesa.json";
in
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
      pkgs.runCommand "${pkg.name}-nixgl"
        {
          nativeBuildInputs = [ pkgs.makeWrapper ];
          # runCommand drops the wrapped package's meta, which loses
          # mainProgram and makes lib.getExe warn. The wrapper recreates every
          # binary under its original basename, so mainProgram still applies.
          # Only carry that one field: the rest of meta describes the original
          # derivation, and outputsToInstall in particular names outputs (man,
          # dev, ...) that this single-output wrapper does not produce.
          meta = lib.optionalAttrs (pkg.meta ? mainProgram) { inherit (pkg.meta) mainProgram; };
        }
        ''
        mkdir -p $out/bin
        nixgl_bin=$(echo ${nixGLWrapper}/bin/*)
        for bin in ${pkg}/bin/*; do
          makeWrapper "$nixgl_bin" $out/bin/$(basename $bin) \
            --add-flags "$bin" \
            --set __EGL_EXTERNAL_PLATFORM_CONFIG_DIRS "${eglPlatformConfigDirs}" \
            --set __EGL_VENDOR_LIBRARY_FILENAMES "${mesaVendorConfig}"
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
