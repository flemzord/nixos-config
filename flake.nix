{
  description = "flemzord's Configuration for NixOS and MacOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
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
    speakeasy-cask = {
      url = "github:speakeasy-api/homebrew-tap";
      flake = false;
    };
    temporal-cask = {
      url = "github:temporalio/homebrew-brew";
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

  outputs = { darwin, nix-homebrew, homebrew-core, homebrew-cask, formancehq-cask, loftsh-cask, earthly-cask, koyeb-cask, speakeasy-cask, temporal-cask, home-manager, nixpkgs, disko, vscode-server, ... }: {
    nixosConfigurations = {
      "home-hp" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          vscode-server.nixosModules.default
          ./hosts/home-hp
        ];
      };

      "home-dell" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/home-dell
          disko.nixosModules.disko
        ];
      };


      "srv-project" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/srv-project
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
                "speakeasy-api/homebrew-tap" = speakeasy-cask;
                "temporalio/homebrew-tap" = temporal-cask;
              };
              mutableTaps = true;
              autoMigrate = true;
            };
          }
          ./hosts/flemzord-MBP
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
          ./hosts/home-mbp
        ];
      };
    };

    # Developer experience
    devShells = {
      x86_64-linux = let pkgs = nixpkgs.legacyPackages.x86_64-linux; in {
        default = pkgs.mkShell {
          packages = with pkgs; [
            nixpkgs-fmt
            statix
            deadnix
            nil
            pre-commit
            git
            direnv
          ];
        };
      };
      aarch64-darwin = let pkgs = nixpkgs.legacyPackages.aarch64-darwin; in {
        default = pkgs.mkShell {
          packages = with pkgs; [
            nixpkgs-fmt
            statix
            deadnix
            nil
            pre-commit
            git
            direnv
          ];
        };
      };
    };

    # Allow `nix fmt`
    formatter = {
      x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;
      aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixpkgs-fmt;
    };
  };
}
