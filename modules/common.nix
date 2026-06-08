{ pkgs, ... }: {
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  time.timeZone = "Europe/Zurich";
  i18n.defaultLocale = "en_US.UTF-8";

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "prohibit-password";
    };
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILWRyI1E93f4fkPc0kNBwD1m+wLIB3kxwsXLM3QEJ9Ys kt@k4080"
  ];

  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    curl
    htop
    (writeShellScriptBin "k-nixos-update" ''
      exec nixos-rebuild switch --flake "github:KeeTraxx/k-nixos#$(hostname)"
    '')
  ];

  nixpkgs.config.allowUnfree = true;

  users.users.root.hashedPasswordFile = "/etc/secrets/users/root";
}
