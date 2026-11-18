# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

Declarative Home Manager configuration using Nix flakes. Manages dev tools, shell, AI agents, and services across machines (macOS and non-NixOS Linux). The current main machine is an Ubuntu x86_64 laptop (`ujjwal-gupta-X510UNR`) that doubles as a home server.

## Key Commands

```bash
# Apply configuration changes (the `hms` zsh alias wraps this)
home-manager switch --flake ~/.config/home-manager --impure

# Update all flake inputs
nix flake update

# Update only AI-related inputs
nix flake update juspay-AI

# Search for a package name
nix search nixpkgs#<name>
```

After any `.nix` file change, the user must run `home-manager switch` (or `hms`) to apply.

**autoWire modules are vendored** in `modules/autowire/` (originally from upstream, see file
headers). They're patched so `readSkills` returns path values rather than `toString`'d strings,
which makes skill dirs real store inputs — no `--option sandbox false` needed.

## Architecture

**Entry point:** `flake.nix` defines inputs (nixpkgs unstable, home-manager, juspay-AI, kolu) and wires modules together in `homeConfigurations`.

**Main config:** `home.nix` is the central file — imports AI agent home modules, defines packages, zsh config, shell aliases, and agent wiring (`programs.opencode`, `programs.claude-code`).

**Modules in `flake.nix` modules list:** New `.nix` modules must be added to the `modules = [...]` array in `flake.nix` to take effect.

**Module pattern:** Each module file uses `{ config, pkgs, lib, ... }:` — only include params you use. Create a separate module when config exceeds ~5 lines.

**AI agent wiring:** Both Claude Code and OpenCode share skills via `autoWire.dirs` pointing to `juspay-AI/.agents` and `./agents/`. Claude Code settings live in `agents/settings/claude-code.nix`. Custom skills go in `agents/skills/<name>/SKILL.md`.

**Cross-platform services:** Use `lib.mkIf pkgs.stdenv.isDarwin` / `lib.mkIf pkgs.stdenv.isLinux` for platform-specific config. macOS uses `launchd.agents`, Linux uses `systemd.user.services`.

## Important Constraints

- **Never install packages imperatively** (no brew, apt, npm -g, pip install). Everything goes through home-manager declaratively.
- **Simple CLI tools** go in `home.packages` in `home.nix`. Tools with configuration use `programs.<name>` modules when available.
- **Config files** for tools without HM modules use `home.file."path".text` or `.source`.
- System and username come from the environment (`--impure`); fallbacks are in `flake.nix`.
- **Host-specific config** lives in `hosts/<name>.nix`, mapped by hostname in `flake.nix` (`hosts = { ... }`).
  `home-manager switch --flake .` picks `"$USER@$(hostname)"` automatically. Keep generic modules
  host-agnostic and gate host behaviour behind options (e.g. `my.homeServer.enable`).
- **Root-level config (non-NixOS Linux)** is also declared in HM: add to `my.systemSetup.{units,etcFiles,disabledServices,extraSteps}`
  (`modules/system-setup.nix`). HM builds an idempotent `hm-system-setup` script; after `hms`, run the
  `sudo .../hm-system-setup` command it prints. Never hand-edit `/etc` or use `apt`/`systemctl enable` directly.
- `nixpkgs` config (e.g. `allowUnfree`) is set in `flake.nix`'s `import nixpkgs`, not via `nixpkgs.config` in modules.
- nixpkgs tracks `nixos-unstable`.
- Secrets are loaded from `~/.config/secrets/` at shell init — never commit secrets.
