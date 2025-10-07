{config, pkgs, ...}:
{
  programs.git = {
    enable = true;
    userEmail = "kt@compile.ch";
    userName = "Khôi Tran";
  };

  programs.foot = {
    enable = true;
    settings = {
      main = {
        term = "xterm-256color";

        font = "Fira Code:size=11";
        dpi-aware = "yes";
      };

      mouse = {
        hide-when-typing = "yes";
      };
    };

  };

  home.stateVersion = "25.05";
}