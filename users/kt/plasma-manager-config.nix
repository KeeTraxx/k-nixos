# created with:
# nix run github:nix-community/plasma-manager > plasma-manager-config.nix
{
  programs.plasma = {
    enable = true;
    workspace = {
      theme = "breeze-dark";
      colorScheme = "BreezeDark";
      cursor = {
        theme = "breeze_cursors";
        size = 24;
      };
      # wallpaper = "~/Pictures/wallpaper.jpg"; # replace with your wallpaper path
    };

    shortcuts = {
      kwin."Window Close" = [
        "Alt+F4"
        "Meta+Shift+Q"
      ];
      "services/foot.desktop"._launch = "Meta+Return";
      "services/org.kde.spectacle.desktop".RectangularRegionScreenShot = "Meta+Shift+S";
    };
    input.touchpads = [
      {
        name = "SynPS/2 Synaptics TouchPad";
        vendorId = "0002";
        productId = "0007";
        naturalScroll = true;
        tapToClick = true;
      }
    ];

    configFile = {
      dolphinrc.DetailsMode.ExpandableFolders = false;
      kdeglobals.General.TerminalApplication = "foot";
      kdeglobals.General.TerminalService = "foot.desktop";
      kwinrc.Desktops.Id_1 = "5a9d9c6c-c2d7-44f6-8ec5-c76690e1b3ed";
      kwinrc.Desktops.Number = 1;
      kwinrc.Desktops.Rows = 1;
      kwinrc.EdgeBarrier.EdgeBarrier = 0;
      kwinrc.Effect-wobblywindows.Drag = 85;
      kwinrc.Effect-wobblywindows.Stiffness = 10;
      kwinrc.Effect-wobblywindows.WobblynessLevel = 1;
      kwinrc.NightColor.Active = true;
      kwinrc.NightColor.Mode = "Constant";
      kwinrc.Plugins.magiclampEnabled = true;
      kwinrc.Plugins.wobblywindowsEnabled = true;
      kwinrc.Wayland."InputMethod[$e]" = "/usr/share/applications/fcitx5-wayland-launcher.desktop";
      kxkbrc.Layout.DisplayNames = "";
      kxkbrc.Layout.LayoutList = "ch";
      kxkbrc.Layout.Options = "terminate:ctrl_alt_bksp,grp:win_space_toggle";
      kxkbrc.Layout.ResetOldOptions = true;
      kxkbrc.Layout.Use = true;
      kxkbrc.Layout.VariantList = "";
      plasma-localerc.Formats.LANG = "en_US.UTF-8";
      plasma-localerc.Formats.LC_ADDRESS = "de_CH.UTF-8";
      plasma-localerc.Formats.LC_MEASUREMENT = "de_CH.UTF-8";
      plasma-localerc.Formats.LC_MONETARY = "de_CH.UTF-8";
      plasma-localerc.Formats.LC_NAME = "de_CH.UTF-8";
      plasma-localerc.Formats.LC_NUMERIC = "de_CH.UTF-8";
      plasma-localerc.Formats.LC_PAPER = "de_CH.UTF-8";
      plasma-localerc.Formats.LC_TELEPHONE = "de_CH.UTF-8";
      plasma-localerc.Formats.LC_TIME = "de_CH.UTF-8";
    };
  };
}
