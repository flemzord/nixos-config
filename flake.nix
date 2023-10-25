{
  description = "flemzord's Configuration for NixOS and MacOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/master";
    agenix.url = "github:ryantm/agenix";
    home-manager.url = "github:nix-community/home-manager";
    darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew = {
      url = "github:zhaofengli-wip/nix-homebrew";
    };
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    formancehq-cask = {
      url = "github:formancehq/homebrew-tap";
      flake = false;
    };
    loftsh-cask = {
      url = "github:loft-sh/homebrew-tap";
      flake = false;
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, darwin, nix-homebrew, homebrew-core, homebrew-cask, formancehq-cask, loftsh-cask, home-manager, nixpkgs, disko, agenix } @inputs: {
    nixosConfigurations = {
      "home-hp" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./machines/home-hp
        ];
      };
    };

    darwinConfigurations = {
      "flemzord-MBP" = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          home-manager.darwinModules.home-manager
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              enable = true;
              user = "flemzord";
              taps = {
                "homebrew/homebrew-core" = homebrew-core;
                "homebrew/homebrew-cask" = homebrew-cask;
                "formancehq/homebrew-tap" = formancehq-cask;
                "loft-sh/homebrew-tap" = loftsh-cask;
              };
              mutableTaps = true;
              autoMigrate = true;
            };
          }
          ./machines/flemzord-MBP
        ];
      };
    };
  };
}
