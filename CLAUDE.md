# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

Declarative Home Manager configuration using Nix flakes. Manages dev tools, shell, AI agents, and services for macOS (aarch64-darwin).

## Key Commands

```bash
# Apply configuration changes (--option sandbox false works around a nix-agent-wire
# bug — see note below; the `hms` zsh alias already wraps this)
home-manager switch --flake ~/.config/home-manager --option sandbox false

# Update all flake inputs
nix flake update

# Update only AI-related inputs
nix flake update nix-agent-wire juspay-AI

# Search for a package name
nix search nixpkgs#<name>
```

After any `.nix` file change, the user must run `home-manager switch` (or `hms`) to apply.

**Known issue:** `nix-agent-wire`'s `readSkills` (in `nix/autowire-lib.nix`) builds skill
paths via `toString dir`, which strips Nix's store-path context. Autowired skill
directories (from `agents/skills/*`) then aren't registered as derivation inputs, so
whichever `opencode-skill` derivation Nix happens to realize fresh on a given run can
fail inside the build sandbox with "OpenCode skill source must be a file or directory" —
non-deterministically, not tied to any specific skill. `--option sandbox false` avoids it
because the build no longer needs the (missing) explicit input to see the source.

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
