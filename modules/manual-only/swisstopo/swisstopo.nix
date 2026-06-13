{ pkgs, ... }:
let
  scripts = pkgs.stdenvNoCC.mkDerivation {
    name = "swisstopo-scripts";
    src = ./bin;
    installPhase = ''
      mkdir -p $out/bin
      for f in $src/*.sh; do
        install -m755 "$f" "$out/bin/$(basename ''${f%.sh})"
      done
    '';
  };
in
{
  home.packages = [ scripts ];

  home.file.".ssh/ssh-config".source = ./ssh/ssh-config;
}
