# Dev Server Design

**Date:** 2025-11-02
**Purpose:** Remote development server configuration for NixOS

## Overview

A minimal, headless NixOS server optimized for remote development work. The server will provide core development tools (Node.js, Python, PHP, Rust) with Docker support, secured via Tailscale VPN, and managed through declarative configuration.

## Requirements

- **Name:** dev-server
- **Platform:** NixOS (x86_64-linux)
- **Access:** Headless (SSH only, no GUI)
- **Services:** Docker only
- **Disk:** Disko-managed declarative partitioning
- **VPN:** Tailscale for secure remote access
- **Updates:** Manual (no auto-upgrade)
- **Packages:** Core dev tools from flemzord-MBP (excluding cloud/k8s tooling)

## Architecture

### File Structure

```
hosts/dev-server/
├── default.nix              # Main host configuration
├── packages.nix             # Core dev tools
├── disk-config.nix          # Disko declarative disk layout
└── hardware-configuration.nix  # Hardware scan (generated on target)
```

### Module Imports

The configuration reuses existing modules:
- `modules/roles/server.nix` - Base server setup (SSH, Tailscale, Zsh, Git)
- `modules/services/docker.nix` - Docker service
- `modules/common/cachix.nix` - Binary cache

### Design Principles

1. **Minimal footprint** - Only essential services
2. **Module reuse** - Leverage existing infrastructure
3. **No cruft** - Unlike home-dell, no additional services (PostgreSQL, Samba, etc.)
4. **Manual control** - No automatic updates
5. **Reproducible** - Disko for declarative disk management

## Configuration Details

### Main Configuration (default.nix)

**Host settings:**
- Hostname: `dev-server`
- System: `x86_64-linux`
- Timezone: `Europe/Paris`
- Locale: `en_US.UTF-8`
- Boot: systemd-boot with EFI
- Network: NetworkManager enabled

**User configuration:**
- User: `flemzord`
- Groups: `wheel`, `docker`, `networkmanager`
- Shell: `zsh`

### Development Packages (packages.nix)

**Language runtimes & package managers:**
- Node.js: nodejs_22, pnpm, yarn, bun
- Python: python313, poetry, uv
- PHP: php84 (with xdebug), composer
- Rust: rustc, cargo
- Build tools: cmake, gnumake

**Version control:**
- git (with filter-repo, LFS)
- gh (GitHub CLI)
- difftastic

**Development environment:**
- direnv
- devenv, devbox
- go-task, process-compose
- mosh

**Utilities:**
- jq, yq
- ripgrep, fd, fzf
- htop, ncdu
- sqlite
- curl, wget

**Explicitly excluded:**
- Kubernetes tools (kubectl, k9s, helm, etc.)
- Cloud CLIs (AWS, GCloud, Hetzner, etc.)
- Terraform, Packer
- Testing tools (k6, newman)
- SaaS CLIs (flyctl, supabase-cli, etc.)

*Note: Excluded tools can be added per-project via devenv/direnv as needed.*

### Disk Configuration (disk-config.nix)

**Layout:**
- Boot: 1GB EFI partition (FAT32, `/boot`)
- Swap: 8GB swap partition
- Root: Remaining space (ext4, `/`)

**Device:** `/dev/sda` (configurable during install)

**Benefits:**
- Simple, proven layout (same as home-dell)
- Adequate swap for development
- Single root partition
- Version-controlled and reproducible

## Integration

### Flake Registration

Add to `flake.nix`:

```nix
nixosConfigurations.dev-server = nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  modules = [
    ./hosts/dev-server
    disko.nixosModules.disko
  ];
};
```

## Deployment

### Initial Installation

On target hardware:
1. Boot NixOS installer ISO
2. Clone config repository
3. Run Disko: `sudo nix run github:nix-community/disko -- --mode disko ./hosts/dev-server/disk-config.nix`
4. Install: `sudo nixos-install --flake .#dev-server`
5. Reboot

### Updates

**Local (on server):**
```bash
git pull
sudo nixos-rebuild switch --flake .#dev-server
```

**Remote (from Mac):**
```bash
nixos-rebuild switch --flake .#dev-server \
  --target-host flemzord@dev-server \
  --use-remote-sudo
```

## Benefits

- **Version-controlled infrastructure** - All config in git
- **Easy rollbacks** - NixOS generations
- **Reproducible** - Can rebuild from scratch with Disko
- **Secure** - Tailscale VPN, SSH only
- **Focused** - Only what's needed for development
- **Maintainable** - Clean, minimal configuration

## Comparison with Existing Hosts

| Feature | dev-server | home-dell | flemzord-MBP |
|---------|-----------|-----------|--------------|
| Platform | NixOS | NixOS | macOS |
| Purpose | Remote dev | Home server | Work laptop |
| GUI | No | No | Yes |
| Docker | Yes | Yes | Yes |
| PostgreSQL | No | Yes | No |
| Samba | No | Yes | No |
| Auto-upgrade | No | Yes | No |
| Dev packages | Core only | Minimal | Complete |
| Tailscale | Yes | Yes | Yes |
| Disko | Yes | Yes | N/A |
