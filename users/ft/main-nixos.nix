{ pkgs, ... }: {
  users.users.ft = {
    isNormalUser = true;
    description = "Flynn Tran";
    extraGroups = [
      "wheel"
      "networkmanager"
      "docker"
    ];
    shell = pkgs.fish;
    hashedPasswordFile = "/etc/secrets/users/ft";
  };
  programs.fish.enable = true;

  home-manager.users.ft = import ./main-home-manager.nix;
}
