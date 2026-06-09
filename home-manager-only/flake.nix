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
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-unstable,
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
        overlays = [
          nixgl.overlays.default
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
        extraSpecialArgs = {
          nixGLWrap = pkg: pkgs.runCommand "${pkg.name}-nixgl" { } ''
            mkdir -p $out/bin
            for bin in ${pkg}/bin/*; do
              name=$(basename $bin)
              echo "#!${pkgs.bash}/bin/bash" > $out/bin/$name
              echo "exec ${pkgs.nixgl.auto.nixGLDefault}/bin/nixGLDefault $bin \"\$@\"" >> $out/bin/$name
              chmod +x $out/bin/$name
            done
          '';
        };
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
