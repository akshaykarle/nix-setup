# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Nix flake-based system configuration repository that manages macOS (nix-darwin), NixOS, and standalone home-manager configurations for multiple machines and users.

## Common Commands

```bash
# Initial setup (installs nix, enables flakes, sets up channels)
./setup.sh

# Apply system configuration (darwin/nixos based on current machine)
./setup.sh switch

# Build without applying (dry-run)
./setup.sh build

# Run flake checks for all configurations
nix flake check

# Format nix files
nixfmt-rfc-style **/*.nix
```

## Architecture

### Flake Structure

The `flake.nix` defines three configuration types via helper functions:
- **`mkDarwinConfig`**: macOS configurations using nix-darwin
- **`mkNixosConfig`**: NixOS configurations
- **`mkHomeConfig`**: Standalone home-manager configurations

Each configuration type follows the pattern `username@arch-os` (e.g., `akshaykarle@aarch64-darwin`).

### Module Organization

```
modules/
├── common.nix          # Shared config imported by both darwin and nixos
├── primaryUser.nix     # Defines `user` and `hm` option aliases
├── nixpkgs.nix         # Nixpkgs configuration
├── darwin/             # macOS-specific modules (brew, preferences, core)
├── nixos/              # NixOS-specific modules
├── home-manager/       # User environment (packages, dotfiles, programs)
└── hardware/           # Machine-specific hardware configs (asus, intel)

profiles/               # User/machine profiles that set user.name
├── darwin.nix          # akshaykarle darwin profile
├── personal.nix        # akshaykarle NixOS profile
└── home.nix            # daksh-home NixOS profile
```

### Key Patterns

- **`user` option**: Custom option defined in `primaryUser.nix` that aliases to `users.users.<name>`
- **`hm` option**: Custom option that aliases to `home-manager.users.<name>` for cleaner config
- **Dotfiles**: Managed via `home.file` in `modules/home-manager/default.nix`, sourced from `dotfiles/`
- **Unfree packages**: Explicitly allowed via `allowUnfreePredicate` lists in both system and home-manager configs
