{config, pkgs, ...}:
{
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.kt = import ./kt.nix;

  # Optionally, use home-manager.extraSpecialArgs to pass
  # arguments to home.nix
}