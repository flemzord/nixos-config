{
  description = "flemzord's Configuration for NixOS and MacOS";

  inputs = {
    # nixpkgs' default branch is 'master' (not 'main')
    nixpkgs.url = "github:nixos/nixpkgs?ref=master";
    nixpkgs-nodejs.url = "github:nixos/nixpkgs/nixos-26.05";
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
    codex-cli-nix = {
      url = "github:sadjow/codex-cli-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hermes-agent = {
      url = "github:NousResearch/hermes-agent";
    };
    googleworkspace-cli = {
      url = "github:googleworkspace/cli";
    };
  };

  outputs = inputs@{ darwin, nix-homebrew, home-manager, nixpkgs, disko, vscode-server, agenix, claude-code-nix, codex-cli-nix, hermes-agent, googleworkspace-cli, ... }: rec {
    overlays.default = final: prev:
      let
        nodejsPkgs = import inputs."nixpkgs-nodejs" {
          system = final.stdenv.hostPlatform.system;
          config.allowUnfree = true;
        };
        nodejsSlim = nodejsPkgs."nodejs-slim_22";
        nodejsWithNpm = final.buildEnv {
          name = "nodejs-slim-${nodejsSlim.version}-with-npm";
          paths = [
            nodejsSlim
            nodejsSlim.corepack
            nodejsSlim.dev
            nodejsSlim.npm
          ];
          extraOutputsToInstall = [
            "corepack"
            "dev"
            "npm"
            "out"
          ];
          ignoreCollisions = true;
          inherit (nodejsSlim) meta;
          passthru = (nodejsSlim.passthru or { }) // {
            inherit (nodejsSlim) corepack libv8 npm version;
            dev = nodejsWithNpm;
          };
        };
      in
      {
        banqline = final.callPackage ./packages/banqline.nix { };
        gitnexus = final.callPackage ./packages/gitnexus.nix { };
        herdr = final.callPackage ./packages/herdr.nix { };
        kubernetes-helm = prev.kubernetes-helm.overrideAttrs (oldAttrs: {
          preCheck = builtins.replaceStrings
            [
              "cmd/helm/dependency_build_test.go"
              "cmd/helm/dependency_update_test.go"
              "cmd/helm/install_test.go"
              "cmd/helm/pull_test.go"
            ]
            [
              "pkg/cmd/dependency_build_test.go"
              "pkg/cmd/dependency_update_test.go"
              "pkg/cmd/install_test.go"
              "pkg/cmd/pull_test.go"
            ]
            oldAttrs.preCheck;
        });
        nodejs_22 = nodejsWithNpm;
        "nodejs-slim_22" = nodejsPkgs."nodejs-slim_22";
        qmd = final.callPackage ./packages/qmd.nix { };
        statix = prev.statix.overrideAttrs (_: {
          doCheck = false;
        });
      };

    packages =
      let
        mkPackages = system:
          let
            pkgs = import nixpkgs {
              inherit system;
              config.allowUnfree = true;
              overlays = [ overlays.default ];
            };
          in
          {
            default = pkgs.qmd;
            inherit (pkgs) banqline;
            inherit (pkgs) gitnexus;
            inherit (pkgs) herdr;
            inherit (pkgs) qmd;
          };
      in
      {
        x86_64-linux = mkPackages "x86_64-linux";
        aarch64-linux = mkPackages "aarch64-linux";
        x86_64-darwin = mkPackages "x86_64-darwin";
        aarch64-darwin = mkPackages "aarch64-darwin";
      };

    nixosConfigurations = {
      "home-hp" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          { nixpkgs.overlays = [ overlays.default ]; }
          agenix.nixosModules.default
          vscode-server.nixosModules.default
          ./hosts/home-hp
        ];
      };

      "home-dell" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          { nixpkgs.overlays = [ overlays.default ]; }
          agenix.nixosModules.default
          disko.nixosModules.disko
          hermes-agent.nixosModules.default
          ./hosts/home-dell
        ];
      };

      "server-dev" = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          {
            nixpkgs.overlays = [
              overlays.default
              claude-code-nix.overlays.default
              codex-cli-nix.overlays.default
              (_final: prev: {
                googleworkspace-cli = googleworkspace-cli.packages.${prev.stdenv.hostPlatform.system}.gws;
              })
            ];
          }
          agenix.nixosModules.default
          disko.nixosModules.disko
          hermes-agent.nixosModules.default
          home-manager.nixosModules.home-manager
          ./hosts/server-dev
        ];
      };
    };

    darwinConfigurations = {
      "laptop-work" = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = { inherit inputs; username = "flemzord"; };
        modules = [
          { nixpkgs.overlays = [ overlays.default claude-code-nix.overlays.default codex-cli-nix.overlays.default ]; }
          agenix.darwinModules.default
          home-manager.darwinModules.home-manager
          nix-homebrew.darwinModules.nix-homebrew
          ./modules/profiles/darwin/common.nix
          ./hosts/laptop-work
        ];
      };
      "laptop-personal" = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = { inherit inputs; username = "flemzord"; };
        modules = [
          { nixpkgs.overlays = [ overlays.default claude-code-nix.overlays.default codex-cli-nix.overlays.default ]; }
          agenix.darwinModules.default
          home-manager.darwinModules.home-manager
          nix-homebrew.darwinModules.nix-homebrew
          ./modules/profiles/darwin/common.nix
          ./hosts/laptop-personal
        ];
      };
    };

    # Developer experience
    devShells =
      let
        common = pkgs: with pkgs; [ nixpkgs-fmt statix deadnix nil pre-commit git direnv agenix.packages.${pkgs.stdenv.hostPlatform.system}.default ];
        mkDevPkgs = system:
          import nixpkgs {
            inherit system;
            config.allowUnfree = true;
            overlays = [ overlays.default ];
          };
      in
      {
        x86_64-linux = let pkgs = mkDevPkgs "x86_64-linux"; in {
          default = pkgs.mkShell { packages = common pkgs; };
        };
        aarch64-darwin = let pkgs = mkDevPkgs "aarch64-darwin"; in {
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
