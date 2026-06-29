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
    nixgl.url = "github:KeeTraxx/nixgl/fix-nvidia-kernel-param";
    nixgl.inputs.nixpkgs.follows = "nixpkgs";
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
      plasma-manager,
      nixgl,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        config.permittedInsecurePackages = [
          "electron-39.8.10"
        ];
        overlays = [
          nixgl.overlays.default
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
      };

      mkHome =
        username:
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            nixGLWrapper = pkgs.nixgl.auto.nixGLNvidia;
          };
          modules = [
            plasma-manager.homeModules.plasma-manager
            ../users/${username}/main-home-manager.nix
            {
              home.username = username;
              home.homeDirectory = "/home/${username}";
              home.sessionVariables.NH_HOME_FLAKE = "github:KeeTraxx/k-nixos?dir=home-manager-only";
            }
          ];
        };
    in
    {
      homeConfigurations = {
        kt = mkHome "kt";
        lttrk = mkHome "lttrk";
      };
    };
}
