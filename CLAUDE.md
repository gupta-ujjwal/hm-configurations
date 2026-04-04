# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

Declarative Home Manager configuration using Nix flakes. Manages dev tools, shell, AI agents, and services for macOS (aarch64-darwin).

## Key Commands

```bash
# Apply configuration changes
home-manager switch --flake ~/.config/home-manager

# Update all flake inputs
nix flake update

# Update only AI-related inputs
nix flake update nix-agent-wire juspay-AI

# Search for a package name
nix search nixpkgs#<name>
```

After any `.nix` file change, the user must run `home-manager switch` to apply.

## Architecture

**Entry point:** `flake.nix` defines inputs (nixpkgs unstable, home-manager, nix-agent-wire, juspay-AI) and wires modules together in `homeConfigurations`.

**Main config:** `home.nix` is the central file — imports AI agent home modules, defines packages, zsh config, shell aliases, and agent wiring (`programs.opencode`, `programs.claude-code`).

**Modules in `flake.nix` modules list:** New `.nix` modules must be added to the `modules = [...]` array in `flake.nix` to take effect.

**Module pattern:** Each module file uses `{ config, pkgs, lib, ... }:` — only include params you use. Create a separate module when config exceeds ~5 lines.

**AI agent wiring:** Both Claude Code and OpenCode share skills via `autoWire.dirs` pointing to `juspay-AI/.agents` and `./agents/`. Claude Code settings live in `agents/settings/claude-code.nix`. Custom skills go in `agents/skills/<name>/SKILL.md`.

**Cross-platform services:** Use `lib.mkIf pkgs.stdenv.isDarwin` / `lib.mkIf pkgs.stdenv.isLinux` for platform-specific config. macOS uses `launchd.agents`, Linux uses `systemd.user.services`.

## Important Constraints

- **Never install packages imperatively** (no brew, apt, npm -g, pip install). Everything goes through home-manager declaratively.
- **Simple CLI tools** go in `home.packages` in `home.nix`. Tools with configuration use `programs.<name>` modules when available.
- **Config files** for tools without HM modules use `home.file."path".text` or `.source`.
- The system is currently `aarch64-darwin` with username `Ujjwal.gupta` — these are set in `flake.nix`.
- nixpkgs tracks `nixos-unstable`.
- Secrets are loaded from `~/.config/secrets/` at shell init — never commit secrets.
