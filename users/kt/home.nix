{ pkgs, ... }: {
  imports = [
    ./plasma-manager-config.nix
    ./git.nix
    ./fish.nix
    ./rust.nix
    ../../modules/swisstopo/swisstopo.nix
    ./foot.nix
  ];
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    unstable.claude-code # pinned to nixos-unstable (see flake.nix overlay)
    talosctl
    rustup
    keepassxc
    jetbrains.idea-oss

  ];

  programs.less.enable = true;
  programs.htop.enable = true;

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
