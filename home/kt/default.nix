{config, pkgs, ...}:
{
  programs.git = {
    enable = true;
    userEmail = "kt@compile.ch";
    userName = "Khôi Tran";
  };

  # sets up ./config/foot/foot.ini
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

  # copies entire .config directory
  home.file.".config" = {
    source = ./.config;
    recursive = true;
  };

  # automatically switch to fish when opening a terminal
  # see: https://nixos.wiki/wiki/Fish
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