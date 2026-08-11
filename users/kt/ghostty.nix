{ pkgs, config, ... }:
{
  home.packages = with pkgs; [
    (config.nixGLWrap ghostty)
  ];
  programs.ghostty = {
    enable = true;
    package = config.nixGLWrap pkgs.ghostty;

    settings = {
      font-size = 14;
      font-family = "Hack Nerd Font";

      # Set to true to get the window frame/titlebar back.
      window-decoration = true;
      window-padding-x = 12;
      window-padding-y = 12;
      background-opacity = 1.0;
      background-blur-radius = 32;

      cursor-style = "block";
      cursor-style-blink = true;

      scrollback-limit = 10000;

      mouse-hide-while-typing = true;
      copy-on-select = true;
      confirm-close-surface = false;

      # Disable annoying copied to clipboard
      app-notifications = "no-clipboard-copy,no-config-reload";

      # Material 3 UI elements
      unfocused-split-opacity = 0.7;
      unfocused-split-fill = "#44464f";

      gtk-titlebar = false;
      gtk-single-instance = true;

      shell-integration = "detect";
      shell-integration-features = "cursor,sudo,title,no-cursor";

      keybind = [
        "ctrl+shift+n=new_window"
        "ctrl+t=new_tab"
        "ctrl+plus=increase_font_size:1"
        "ctrl+minus=decrease_font_size:1"
        "ctrl+zero=reset_font_size"
        "shift+enter=text:\\n"
      ];

      theme = "dankcolors";
    };

    # Generated once by the Dank color tooling; kept static here so the theme
    # survives a fresh checkout. Regenerating it externally will fail against
    # the read-only store path.
    themes.dankcolors = {
      background = "#101418";
      foreground = "#e0e2e8";
      cursor-color = "#9dcbfb";
      selection-background = "#124a73";
      selection-foreground = "#e0e2e8";
      palette = [
        "0=#101418"
        "1=#d75a59"
        "2=#8ed88c"
        "3=#e0d99d"
        "4=#4087bc"
        "5=#839fbc"
        "6=#9dcbfb"
        "7=#abb2bf"
        "8=#5c6370"
        "9=#e57e7e"
        "10=#a2e5a0"
        "11=#efe9b3"
        "12=#a7d9ff"
        "13=#3d8197"
        "14=#5c7ba3"
        "15=#ffffff"
      ];
    };
  };
}
