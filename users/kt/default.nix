{ pkgs, ... }: {
  users.users.kt = {
    isNormalUser = true;
    description = "Khôi Tran";
    extraGroups = [
      "wheel"
      "networkmanager"
      "docker"
    ];
    shell = pkgs.fish;
    hashedPasswordFile = "/etc/secrets/users/kt";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILWRyI1E93f4fkPc0kNBwD1m+wLIB3kxwsXLM3QEJ9Ys kt@k4080"
    ];
  };
  programs.fish.enable = true;

  home-manager.users.kt = import ./home.nix;
}
