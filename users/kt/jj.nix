{ pkgs, ... }:
let
  tomlFormat = pkgs.formats.toml { };
in
{
  programs.jujutsu = {
    enable = true;
    settings = {
      user.name = "Khôi Tran";
      user.email = "kt@compile.ch";
    };
  };

  # Conditional identity per repository path.
  #
  # This lives in conf.d/ rather than as a `[[--scope]]` block inside
  # `programs.jujutsu.settings`: that form is a TOML array of tables, which
  # pkgs.formats.toml flattens into a plain table, and jj then rejects the whole
  # config with "Expected an array of tables, but is table". A per-file top-level
  # `--when` is equivalent and survives the round-trip through Nix.
  xdg.configFile."jj/conf.d/swisstopo.toml".source = tomlFormat.generate "jj-swisstopo" {
    "--when".repositories = [ "~/projects/swisstopo" ];
    user = {
      name = "Khôi Tran";
      email = "khoi.tran@swisstopo.ch";
    };
  };
}
