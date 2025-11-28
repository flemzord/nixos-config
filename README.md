<img src="https://user-images.githubusercontent.com/1292576/190241835-41469235-f65d-4d4b-9760-372cdff7a70f.png" width="48">

# Nix / NixOS config

_Psst: I can help write Nix at your company. <a href="https://twitter.com/flemzord">Get in touch.</a>_
# Overview
Hey, you made it! Welcome. 🤓

This is my personal NixOS configuration, which I use on my personal computers and servers. It's a work in progress, but it's already pretty cool. I'm sharing it here in case it's useful to others.

## Structure
- `hosts/<host>`: per‑host configs (NixOS and macOS).
- `modules/`: reusable modules (`services/`, `programs/`, `roles/`, `common/`).
- `flake.nix`: flake inputs/outputs; `Makefile`: convenience targets.

## Dev environment
- Enable direnv with `direnv allow` (see `.envrc`).
- Enter dev shell: `nix develop` (provides `nixpkgs-fmt`, `statix`, `deadnix`, `nil`, `pre-commit`).
- Common commands: `make fmt`, `make lint` (non-bloquant), `make lint-ci` (strict), `make build`, `make check`.

# Bootstrap New Computer

## For MacOS, install Nix package manager and dependencies
```sh
xcode-select --install
```
```sh
sh <(curl -L https://nixos.org/nix/install) --daemon
```
```sh
make switch
```
## Update dependencies
```sh
nix flake update
```

## Secrets Management (agenix)

Secrets are encrypted with [agenix](https://github.com/ryantm/agenix) using age encryption.

### Edit a secret
```sh
nix develop
agenix -e secrets/ssh-config.age
```

### Re-encrypt all secrets (after adding a key to secrets.nix)
```sh
nix develop
agenix -r
```

### Apply changes after editing secrets
```sh
make switch
sudo launchctl kickstart system/org.nixos.activate-agenix  # macOS only
```

### Add a new secret
1. Add the secret definition in `secrets.nix`
2. Create and encrypt: `agenix -e secrets/my-secret.age`
3. Reference it in your module with `age.secrets.my-secret.file`
