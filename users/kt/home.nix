{ pkgs, ... }: {
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    ripgrep
    fd
    bat
    eza
    fzf
    jq
  ];

  programs.git = {
    enable = true;
    settings = {
      user.name = "Khôi Tran";
      user.email = "kt@compile.ch";
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
    };
  };

  programs.fish.enable = true;

  programs.starship.enable = true;
}
