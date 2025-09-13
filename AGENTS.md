# Repository Guidelines

## Build, Test, and Development Commands
- **Build**: `make build` — Build without switching (platform-aware: darwin/nixos configs)
- **Apply**: `make switch` — Build and apply config (set `NIXNAME=<host>` for specific host)
- **Format**: `make fmt` or `nix fmt` — Format all Nix files with nixpkgs-fmt
- **Lint**: `make lint` — Run statix check and deadnix (dev-friendly, non-failing)
- **Strict Lint**: `make lint-ci` — Strict linting for CI (fails on issues)
- **Pre-commit**: `pre-commit run -a` — Run all hooks (statix fix + nixpkgs-fmt + deadnix)
- **Test/Validate**: `nix flake check` or `nix build .#darwinConfigurations.<host>.system`
- **Update deps**: `make update` — Update and commit flake.lock

## Code Style & Conventions
- **Language**: Nix exclusively
- **Indentation**: 2 spaces, LF line endings, UTF-8 (enforced by .editorconfig)
- **Formatting**: Use `nixpkgs-fmt` (automated via pre-commit hooks)
- **Linting**: Use `statix` for best practices, `deadnix` for unused code detection
- **Structure**: hosts/<hostname>/{default.nix,packages.nix,casks.nix}, modules/{programs,services,roles,common}/
- **Naming**: Snake_case for attributes, kebab-case for filenames, descriptive module names
- **Imports**: Group by category (nixpkgs, inputs, local modules), sort alphabetically
- **Error Handling**: Use lib.mkDefault for overridable defaults, assertions for validation

## Coding Style & Naming Conventions
- Indentation: 2 spaces, LF, UTF‑8 (see `.editorconfig`).
- Language: Nix. Format with `nixpkgs-fmt` and lint with `statix`.
  - Install hooks: `pre-commit install`; run: `pre-commit run -a`.
- Naming:
  - Hosts: `hosts/<hostname>` with `default.nix`, optional `packages.nix`, `casks.nix`.
  - Services/Programs: one module per file under `modules/services` or `modules/programs`.

## Commit Guidelines  
- **Format**: Conventional Commits (`feat(scope):`, `fix(scope):`, `chore:`)
- **Scopes**: host names (`home-hp`, `flemzord-MBP`) or module names (`samba`, `packages`, `casks`)
- **Pre-commit**: Always run `pre-commit run -a` before committing (formats + lints)
- **Validation**: Build-test changes with `make build` or `nix build .#<config>` before commit
