{
  description = "flemzord's Configuration for NixOS and MacOS";

  inputs = {
    # nixpkgs' default branch is 'master' (not 'main')
    nixpkgs.url = "github:nixos/nixpkgs?ref=master";
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
    charmbracelet-cask = {
      url = "github:charmbracelet/homebrew-tap";
      flake = false;
    };
    darksworm-cask = {
      url = "github:darksworm/homebrew-tap";
      flake = false;
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
    };
    claude-code-nix = {
      url = "github:sadjow/claude-code-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { darwin, nix-homebrew, homebrew-core, homebrew-cask, formancehq-cask, loftsh-cask, earthly-cask, koyeb-cask, speakeasy-cask, temporal-cask, charmbracelet-cask, darksworm-cask, home-manager, nixpkgs, disko, vscode-server, agenix, claude-code-nix, ... }: {
    nixosConfigurations = {
      "home-hp" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          agenix.nixosModules.default
          vscode-server.nixosModules.default
          ./hosts/home-hp
        ];
      };

      "home-dell" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          agenix.nixosModules.default
          disko.nixosModules.disko
          ./hosts/home-dell
        ];
      };

      "dev-server" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          agenix.nixosModules.default
          disko.nixosModules.disko
          ./hosts/dev-server
        ];
      };
    };

    darwinConfigurations = {
      "flemzord-MBP" = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          { nixpkgs.overlays = [ claude-code-nix.overlays.default ]; }
          agenix.darwinModules.default
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
                "charmbracelet/homebrew-tap" = charmbracelet-cask;
                "darksworm/homebrew-tap" = darksworm-cask;
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

    homeConfigurations = {
      "flemzord@dev" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
          overlays = [ claude-code-nix.overlays.default ];
        };
        modules = [ ./hosts/dev ];
      };
    };

    # Developer experience
    devShells = let
      common = pkgs: with pkgs; [ nixpkgs-fmt statix deadnix nil pre-commit git direnv agenix.packages.${pkgs.system}.default ];
    in {
      x86_64-linux = let pkgs = nixpkgs.legacyPackages.x86_64-linux; in {
        default = pkgs.mkShell { packages = common pkgs; };
      };
      aarch64-darwin = let pkgs = nixpkgs.legacyPackages.aarch64-darwin; in {
        default = pkgs.mkShell { packages = common pkgs; };
      };
    };

    # Allow `nix fmt`
    formatter = {
      x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;
      aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixpkgs-fmt;
    };
  };
}
