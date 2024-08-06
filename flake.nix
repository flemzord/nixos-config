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
    earthly-cask = {
      url = "github:earthly/homebrew-earthly";
      flake = false;
    };
    koyeb-cask = {
      url = "github:koyeb/homebrew-tap";
      flake = false;
    };
    vector-cask = {
      url = "github:vectordotdev/homebrew-brew";
      flake = false;
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
    };
  };

  outputs = { self, darwin, nix-homebrew, homebrew-core, homebrew-cask, formancehq-cask, loftsh-cask, earthly-cask, koyeb-cask, home-manager, nixpkgs, disko, agenix, vscode-server, vector-cask } @inputs: {
    nixosConfigurations = {
      "home-hp" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          vscode-server.nixosModules.default
          ./machines/home-hp
        ];
      };

      "home-dell" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./machines/home-dell
          disko.nixosModules.disko
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
                "earthly/homebrew-earthly" = earthly-cask;
                "koyeb/homebrew-tap" = koyeb-cask;
                "vectordotdev/brew" = vector-cask;
              };
              mutableTaps = true;
              autoMigrate = true;
            };
          }
          ./machines/flemzord-MBP
        ];
      };
      "home-mbp" = darwin.lib.darwinSystem {
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
              };
              mutableTaps = true;
              autoMigrate = true;
            };
          }
          ./machines/home-mbp
        ];
      };
    };
  };
}
