{ pkgs, ... }: {
  imports = [ ./plasma-manager-config.nix ];
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    unstable.claude-code # pinned to nixos-unstable (see flake.nix overlay)
    talosctl
    foot
  ];

  programs.git = {
    enable = true;
    settings = {
      user.name = "Khôi Tran";
      user.email = "kt@compile.ch";
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      pull.rebase = true;
      rebase.autoStash = true;
    };
  };

  programs.fish.enable = true;

  programs.plasma = {
    enable = true;

    workspace = {
      theme = "breeze-dark";
      colorScheme = "BreezeDark";
      cursor = {
        theme = "breeze_cursors";
        size = 24;
      };
      iconTheme = "breeze-dark";
      # wallpaper = "~/Pictures/wallpaper.jpg"; # replace with your wallpaper path
    };
  };
}
