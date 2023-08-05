{
  description = "flemzord's Configuration for NixOS and MacOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/master";
    home-manager.url = "github:nix-community/home-manager";
    darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, darwin, home-manager, nixpkgs, disko, ... }@inputs: {
    nixosConfigurations = {
        "home-hp" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./machines/home-hp
          ];
        };
    };

    darwinConfigurations = {
      "flemzords-MBP" = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [ ./darwin ];
      };
    };
  };
}
