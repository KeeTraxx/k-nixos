{ pkgs, config, ... }:
{
  home.packages = with pkgs; [
    (config.nixGLWrap unstable.zed-editor)
  ];
  home.shellAliases = {
    zed = "zeditor";
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
