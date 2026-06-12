{ ... }: {
  programs.git = {
    enable = true;
    settings = {
      user.name = "Flynn Tran";
      user.email = "flynn.tran15@gmail.com";
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      pull.rebase = true;
      rebase.autoStash = true;
    };
    lfs.enable = true;
  };
}
