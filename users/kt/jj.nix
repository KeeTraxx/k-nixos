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

      remotes.origin = {
        # Track every bookmark pushed to origin, not just the ones fetched at
        # clone time.
        auto-track-bookmarks = "*";
        # Bookmarks created locally track origin too, like git's
        # push.autoSetupRemote.
        auto-track-created-bookmarks = "*";
      };

      # Refuse to push scratch commits.
      git.private-commits = ''description(glob:"wip:*") | description(glob:"private:*")'';

      # jj errors out instead of snapshotting new files above this size; the
      # 1MiB default is easy to trip over in repos with binaries.
      snapshot.max-new-file-size = "10MiB";
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
