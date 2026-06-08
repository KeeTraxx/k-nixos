{
  description = "k-nixos system configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, disko, ... }:
    let
      lib = nixpkgs.lib;

      # Auto-discover hosts from the hosts/ directory
      hostNames = lib.attrNames (
        lib.filterAttrs (_: type: type == "directory") (builtins.readDir ./hosts)
      );

      mkHost = hostname:
        lib.nixosSystem {
          modules = [
            disko.nixosModules.disko
            ./hosts/${hostname}/default.nix
            ./modules/k-nixos-update.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              # Expose unstable packages as pkgs.unstable everywhere,
              # including home-manager (via useGlobalPkgs).
              nixpkgs.overlays = [
                (final: _: {
                  unstable = import nixpkgs-unstable {
                    system = final.stdenv.hostPlatform.system;
                    config.allowUnfree = true;
                  };
                })
              ];
            }
          ];
        };
    in
    {
      nixosConfigurations = lib.genAttrs hostNames mkHost;
    };
}
