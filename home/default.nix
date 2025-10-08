{config, pkgs, ...}:
{
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.kt = import ./kt;

  # Optionally, use home-manager.extraSpecialArgs to pass
  # arguments to home.nix
}