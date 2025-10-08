{ config, pkgs, ... }:
{
  users.users.kt = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "docker" ];
    # it's possible to set password with hashedPassword
    # see `mkpasswd --method=SHA-512 myPassword` from package `whois`
    # hashedPassword = "...";
  };

}