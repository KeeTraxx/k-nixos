{ pkgs, ... }: {
  users.users.kt = {
    isNormalUser = true;
    description = "Khôi Tran";
    extraGroups = [ "wheel" "networkmanager" "docker" ];
    shell = pkgs.fish;
  };

  programs.fish.enable = true;

  home-manager.users.kt = import ./home.nix;
}
