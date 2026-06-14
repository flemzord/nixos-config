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

<!-- gitnexus:start -->
# GitNexus — Code Intelligence

This project is indexed by GitNexus as **nixos-config** (403 symbols, 579 relationships, 19 execution flows). Use the GitNexus MCP tools to understand code, assess impact, and navigate safely.

> If any GitNexus tool warns the index is stale, run `npx gitnexus analyze` in terminal first.

## Always Do

- **MUST run impact analysis before editing any symbol.** Before modifying a function, class, or method, run `gitnexus_impact({target: "symbolName", direction: "upstream"})` and report the blast radius (direct callers, affected processes, risk level) to the user.
- **MUST run `gitnexus_detect_changes()` before committing** to verify your changes only affect expected symbols and execution flows.
- **MUST warn the user** if impact analysis returns HIGH or CRITICAL risk before proceeding with edits.
- When exploring unfamiliar code, use `gitnexus_query({query: "concept"})` to find execution flows instead of grepping. It returns process-grouped results ranked by relevance.
- When you need full context on a specific symbol — callers, callees, which execution flows it participates in — use `gitnexus_context({name: "symbolName"})`.

## Never Do

- NEVER edit a function, class, or method without first running `gitnexus_impact` on it.
- NEVER ignore HIGH or CRITICAL risk warnings from impact analysis.
- NEVER rename symbols with find-and-replace — use `gitnexus_rename` which understands the call graph.
- NEVER commit changes without running `gitnexus_detect_changes()` to check affected scope.

## Resources

| Resource | Use for |
|----------|---------|
| `gitnexus://repo/nixos-config/context` | Codebase overview, check index freshness |
| `gitnexus://repo/nixos-config/clusters` | All functional areas |
| `gitnexus://repo/nixos-config/processes` | All execution flows |
| `gitnexus://repo/nixos-config/process/{name}` | Step-by-step execution trace |

## CLI

| Task | Read this skill file |
|------|---------------------|
| Understand architecture / "How does X work?" | `.claude/skills/gitnexus/gitnexus-exploring/SKILL.md` |
| Blast radius / "What breaks if I change X?" | `.claude/skills/gitnexus/gitnexus-impact-analysis/SKILL.md` |
| Trace bugs / "Why is X failing?" | `.claude/skills/gitnexus/gitnexus-debugging/SKILL.md` |
| Rename / extract / split / refactor | `.claude/skills/gitnexus/gitnexus-refactoring/SKILL.md` |
| Tools, resources, schema reference | `.claude/skills/gitnexus/gitnexus-guide/SKILL.md` |
| Index, status, clean, wiki CLI commands | `.claude/skills/gitnexus/gitnexus-cli/SKILL.md` |

<!-- gitnexus:end -->
