{ config, pkgs, ... }:
{
  users.users.kt = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "docker" ];
  };

}