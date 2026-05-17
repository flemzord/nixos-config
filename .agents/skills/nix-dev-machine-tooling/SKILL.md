---
name: nix-dev-machine-tooling
description: Work on this Nix configuration for developer tooling. Use when adding CLI packages, overlays, Darwin packages, server-dev packages, Hermes services, Codex/Claude config, Home Manager modules, `make switch`, `nix flake check`, pre-commit, statix, deadnix, or nixpkgs-fmt fixes.
---

# Nix Dev Machine Tooling

## Overview

Use this skill for changes to developer-machine tooling managed by this Nix repo. Keep changes declarative, host/profile-specific, formatted, and validated with the repo's normal commands.

## Repository Map

Important paths:

- `packages/` for custom package derivations such as `qmd`, `gitnexus`, `xurl`, and `herdr`
- `modules/profiles/common/dev-packages.nix` for shared developer packages
- `modules/profiles/darwin/packages.nix` for Darwin defaults
- `modules/profiles/nixos/packages.nix` and `modules/profiles/nixos/dev.nix` for NixOS/dev defaults
- `hosts/server-dev/` for the dev server host
- `modules/services/hermes-*.nix` for Hermes services
- `modules/home-manager/programs/codex.nix` and `modules/home-manager/programs/claude-code.nix` for AI tooling configuration

Read `AGENTS.md` before changing validation or style assumptions.

## Adding a CLI Package

When the user asks to add a GitHub CLI tool:

1. Inspect existing package derivations in `packages/` and copy the closest pattern.
2. Verify upstream language/tooling before choosing `buildGoModule`, `buildNpmPackage`, `rustPlatform.buildRustPackage`, or a simple binary fetch.
3. Add the package to the appropriate shared profile:
   - Darwin by default when the user says "sur Darwin"
   - `server-dev` or NixOS dev profile when Hermes/server usage is requested
   - common dev package profile only when it should exist everywhere
4. Avoid managing mutable runtime config files such as Codex/Claude `config.toml` or `settings.json` unless the user explicitly asks; these have caused workflow friction.

## Validation

Use repo commands:

```bash
make fmt
make lint
pre-commit run -a
make build
```

For a specific host:

```bash
NIXNAME=<host> make build
NIXNAME=<host> make switch
```

Use `make switch` only when the user asked to apply changes locally or when applying is necessary to verify the requested machine state. If the command fails because of network, cache, or external package issues, report the exact failure and whether the Nix code itself evaluated.

## Hermes and Server-Dev

For Hermes-related requests:

- distinguish between installing a CLI for the `hermes` user/process and configuring Hermes service behavior
- inspect `modules/services/hermes-*.nix`, secrets references, and `hosts/server-dev/`
- do not expose age secret values in responses
- after deployment, verify services with the available systemd or SSH path only when the user asked for deployment/verification

## Reporting

Report changed package/profile paths, validation commands and results, whether `make switch` was run, and any host still needing manual application.
