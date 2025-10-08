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
    source = ./.config;
    recursive = true;
  };

  programs.bash = {
    initExtra = ''
      if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
      then
        shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
        exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
      fi
    '';
  };

  home.stateVersion = "25.05";
}