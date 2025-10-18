{
  description = "K-NixOS. NixOS on a silver platter.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-25.05";

    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };


  outputs =
    inputs@{
      self,
      nixpkgs,
      nixpkgs-unstable,
      home-manager
    }:
    {
    nixosConfigurations.t-11 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit nixpkgs-unstable; };
      modules = [
        ./hosts/t-11.nix
        ./type/desktop.nix
        home-manager.nixosModules.home-manager
        ./home
      ];
    };

    nixosConfigurations.k4080 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit nixpkgs-unstable; };
      modules = [
        ./hosts/k4080.nix
        ./type/desktop-nvidia.nix
        home-manager.nixosModules.home-manager
        ./home
      ];
    };

  };
}