{ pkgs, config, ... }:
{
  home.packages = with pkgs; [
    (config.nixGLWrap unstable.zed-editor)
    unstable.claude-agent-acp
  ];
  home.shellAliases = {
    zed = "zeditor";
  };

  # Only manage settings; zed itself is installed above (nixGL-wrapped).
  # mutableUserSettings (default) merges these keys into the existing
  # settings.json on each switch, so settings changed in zed are kept.
  programs.zed-editor = {
    enable = true;
    package = null;
    userSettings = {
      buffer_font_family = "FantasqueSansM Nerd Font";
      terminal.font_family = "FantasqueSansM Nerd Font";
    };
  };

  xdg.desktopEntries."dev.zed.Zed" = {
    name = "Zed";
    genericName = "Text Editor";
    comment = "A high-performance, multiplayer code editor.";
    exec = "zeditor %U";
    icon = "${pkgs.zed-editor}/share/icons/hicolor/512x512/apps/zed.png";
    terminal = false;
    type = "Application";
    categories = [
      "Utility"
      "TextEditor"
      "Development"
      "IDE"
    ];
    mimeType = [
      "text/plain"
      "application/x-zerosize"
      "x-scheme-handler/zed"
    ];
    startupNotify = true;
    actions = {
      "NewWorkspace" = {
        exec = "zeditor --new %U";
        name = "Open a new workspace";
      };
    };
  };
}
