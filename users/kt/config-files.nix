{ lib, ... }:
let
  configDir = ./.config;
  files = lib.filesystem.listFilesRecursive configDir;
in {
  home.file = lib.listToAttrs (map (file: {
    name = ".config/" + lib.removePrefix (toString configDir + "/") (toString file);
    value = { source = file; };
  }) files);
}
