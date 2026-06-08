{ pkgs, ... }: {
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    unstable.claude-code  # pinned to nixos-unstable (see flake.nix overlay)
    talosctl
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
}
