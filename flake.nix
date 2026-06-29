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
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    nixpkgs-logseq-pr = {
      url = "github:NixOS/nixpkgs/pull/536292/head";
      flake = false;
    };
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-unstable,
      nixpkgs-logseq-pr,
      home-manager,
      disko,
      plasma-manager,
      ...
    }:
    let
      lib = nixpkgs.lib;

      # Auto-discover hosts from the hosts/ directory
      hostNames = lib.attrNames (
        lib.filterAttrs (_: type: type == "directory") (builtins.readDir ./hosts)
      );

      mkHost =
        hostname:
        lib.nixosSystem {
          modules = [
            disko.nixosModules.disko
            ./hosts/${hostname}/nixos-base.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.sharedModules = [ plasma-manager.homeModules.plasma-manager ];
              # Expose unstable packages as pkgs.unstable everywhere,
              # including home-manager (via useGlobalPkgs).
              nixpkgs.overlays = [
                (final: _: {
                  unstable = import nixpkgs-unstable {
                    system = final.stdenv.hostPlatform.system;
                    config.allowUnfree = true;
                  };
                  logseq = (import nixpkgs-logseq-pr {
                    system = final.stdenv.hostPlatform.system;
                    config.allowUnfree = true;
                    config.permittedInsecurePackages = [
                      "electron-39.8.10"
                    ];
                  }).logseq;
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
