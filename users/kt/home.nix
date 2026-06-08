{ pkgs, ... }: {
  home.stateVersion = "24.11";

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
    userName = "Khôi Tran";
    userEmail = "kt@compile.ch";
    extraConfig = {
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
    };
  };

  programs.fish.enable = true;

  programs.starship.enable = true;
}
