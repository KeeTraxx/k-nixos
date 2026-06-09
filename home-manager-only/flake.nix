{
  description = "standalone home-manager configuration for kt";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      plasma-manager,
      ...
    }:
    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
        overlays = [
          (final: _: {
            unstable = import nixpkgs-unstable {
              system = final.stdenv.hostPlatform.system;
              config.allowUnfree = true;
            };
          })
        ];
      };
    in
    {
      homeConfigurations."kt" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          plasma-manager.homeModules.plasma-manager
          ../users/kt/home.nix
          {
            home.username = "kt";
            home.homeDirectory = "/home/kt";
          }
        ];
      };
    };
}
