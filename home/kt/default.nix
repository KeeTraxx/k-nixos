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

        font = "FiraCode Nerd Font Mono:size=11";
        dpi-aware = "yes";
      };

      mouse = {
        hide-when-typing = "yes";
      };
    };

  };

  home.file.".config" = {
    source = ./config;
    recursive = true;
  };

  home.stateVersion = "25.05";
}