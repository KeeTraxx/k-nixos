{ pkgs, config, ... }:
{
  home.packages = with pkgs; [
    (config.nixGLWrap mesa-demos) # glxgears
    (config.nixGLWrap vulkan-tools) # vkcube vkgears
    (config.nixGLWrap godot)
    (config.nixGLWrap logseq)
    (config.nixGLWrap drawio)
    (config.nixGLWrap unstable.zed-editor)
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.hack
    (config.nixGLWrap keepassxc)
    (config.nixGLWrap jetbrains.idea-oss)
  ];
  home.shellAliases = {
    zed = "zeditor";
    m = "__EGL_VENDOR_LIBRARY_FILENAMES=/usr/share/glvnd/egl_vendor.d/50_mesa.json wl-mirror --fullscreen eDP-1";
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
