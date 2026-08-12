{ ... }: {
  programs.git = {
    enable = true;
    ignores = [
      ".idea/"
      "**/.claude/settings.local.json"
    ];
    settings = {
      user.name = "Khôi Tran";
      user.email = "kt@compile.ch";
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      pull.rebase = true;
      rebase.autoStash = true;
    };
    includes = [
      {
        condition = "gitdir:~/projects/swisstopo/";
        contents.user = {
          name = "Khôi Tran";
          email = "khoi.tran@swisstopo.ch";
        };
      }
    ];
    lfs.enable = true;
  };
}
