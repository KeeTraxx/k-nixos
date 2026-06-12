{ pkgs, lib, ... }: {
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
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

  # Only manage the root password when the secrets file has been deployed
  # (i.e. after the first install.sh run). This prevents activation failures
  # on machines that predate the hashedPasswordFile setup.
  users.users.root.hashedPasswordFile = lib.mkIf (builtins.pathExists /etc/secrets/users/root) "/etc/secrets/users/root";

  environment.systemPackages = with pkgs; [
    # cli tools
    htop
    p7zip
    bat
    mc
    dust # better du
    ncdu # du with tui
    dog # better dig
    rsync
    nmap # ncat for gdscript language server
    yq # yaml query tool
    jq # json query tool

    # nix specific
    nixd
    nil
    nvd
    nh
  ];

  nixpkgs.config.allowUnfree = true;
}
