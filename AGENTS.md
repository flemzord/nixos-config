# Repository Guidelines

## Project Structure & Module Organization
- `flake.nix`/`flake.lock`: Entry point and inputs/outputs for Nix flakes.
- `hosts/<host>`: Per‑host NixOS/darwin configs (e.g., `home-hp`, `flemzord-MBP`).
- `modules/`: Reusable modules
  - `programs/` and `services/`: Program/service modules (e.g., `samba.nix`).
  - `roles/`: Role bundles (e.g., `server.nix`).
  - `common/`: Shared bits (e.g., `cachix.nix`, `packages.nix`).
- `Makefile`: Convenience targets for apply/update.
- `.pre-commit-config.yaml`, `.editorconfig`: Formatting and linting.

## Build, Test, and Development Commands
- `make switch` — Build and apply the current host config.
  - macOS: builds `.#darwinConfigurations.${NIXNAME}.system` and runs `darwin-rebuild switch`.
  - Linux: runs `sudo nixos-rebuild switch --flake .#${NIXNAME}`.
  - Example: `NIXNAME=flemzord-MBP make switch`.
- `make update` — Update flake inputs and commit `flake.lock`.
- Useful Nix commands:
  - `nix flake show` — Inspect available outputs.
  - `nix build .#darwinConfigurations.<host>.system` — Build without switching.
  - `sudo nixos-rebuild build --flake .#<host>` — NixOS build only.

## Coding Style & Naming Conventions
- Indentation: 2 spaces, LF, UTF‑8 (see `.editorconfig`).
- Language: Nix. Format with `nixpkgs-fmt` and lint with `statix`.
  - Install hooks: `pre-commit install`; run: `pre-commit run -a`.
- Naming:
  - Hosts: `hosts/<hostname>` with `default.nix`, optional `packages.nix`, `casks.nix`.
  - Services/Programs: one module per file under `modules/services` or `modules/programs`.

## Testing Guidelines
- Lint/format before commit: `pre-commit run -a` (runs `statix fix` and `nixpkgs-fmt`).
- Validate evaluation/build:
  - macOS: `nix build .#darwinConfigurations.<host>.system`.
  - NixOS: `sudo nixos-rebuild build --flake .#<host>` (dry build).
- Optional: `nix flake check` for generic flake checks if added.

## Commit & Pull Request Guidelines
- Use Conventional Commits: `feat(scope): ...`, `fix(scope): ...`, `chore: ...`.
  - Scopes examples: `home-hp`, `samba`, `casks`, `packages`.
- PRs should include:
  - Summary of changes and affected hosts.
  - Test steps/commands used (build/dry‑run), and any risk notes.
  - Linked issues (if any). Screenshots only when UI/UX is impacted (rare here).

## Security & Configuration Tips
- Prefer encrypted secrets via agenix (`*.age`) and avoid committing new plaintext files under `secrets/`.
- macOS prerequisites: Xcode CLT and Nix installed (see README). Set `NIXNAME` accordingly.
- Linux: some hosts may require `NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1` (handled in `Makefile`).
