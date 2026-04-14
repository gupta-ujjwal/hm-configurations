# hm-configurations

Declarative Home Manager setup using Nix flakes. Manages development tools, shell environment, AI coding agents, and services — reproducible across machines.

## Quick Install

```bash
nix run github:gupta-ujjwal/hm-configurations
```

This single command will:
1. Auto-detect your system, username, and home directory
2. Clone the repo to `~/.config/home-manager`
3. Apply the full home-manager configuration

**Prerequisites:** [Nix with flakes enabled](https://install.determinate.systems/nix)

## Configured Tools

### Core Development
- **Neovim** — CoC + Haskell LSP, telescope, fugitive, dracula theme
- **Tmux** — vi-mode, `Ctrl-a` prefix, mouse support
- **Tmate** — instant terminal sharing
- **Git** + **Lazygit** — version control
- **Zsh** — completions, syntax highlighting, autosuggestions, starship prompt

### Languages & Runtimes
- **Haskell** — Stack
- **Python 3.13** — uv package manager
- **Node.js 24** — includes xyne-cli

### Databases
- **Redis** — systemd service (Linux) / launchd (macOS) with persistent config
- **MariaDB**, **PostgreSQL**

### AI Coding Agents
- **Claude Code** — Anthropic's CLI agent, configured via [nix-agent-wire](https://github.com/srid/nix-agent-wire)
- **OpenCode** — configured via [juspay/AI](https://github.com/juspay/AI) with Juspay LiteLLM provider
- **Shared skills** — 9 skills from juspay/AI + custom skills in `agents/`, wired into both tools via `autoWire.dirs`
- **OpenCode plugins** — superpowers, playwright MCP server

### Infrastructure
- **Docker** + **Colima** — container runtime
- **Netbird** — VPN daemon (systemd service)
- **direnv** + **nix-direnv** — per-project environments
- **fzf**, **ripgrep**, **htop**, **btop**, **nix-index**

### Fonts
- JetBrains Mono Nerd Font

## Manual Setup

If you prefer not to use the bootstrap script:

```bash
git clone https://github.com/gupta-ujjwal/hm-configurations.git ~/.config/home-manager
cd ~/.config/home-manager
home-manager switch --flake . --impure
```

The `--impure` flag allows auto-detection of your `$USER` and `$HOME`. No manual editing of `flake.nix` or `home.nix` is needed.

## Repository Structure

```
.
├── flake.nix              # Flake inputs: nixpkgs, home-manager, nix-agent-wire, juspay/AI
├── flake.lock
├── home.nix               # Main config: packages, zsh, aliases, agent wiring
├── bootstrap.sh           # Bootstrap script for single-command setup
├── modules/
│   ├── neovim.nix         # Neovim + CoC + plugins
│   ├── tmux.nix           # Tmux config
│   ├── tmate.nix          # Tmate config
│   ├── redis.nix          # Redis service (systemd/launchd) + config
│   └── opencode-config.nix # OpenCode settings: providers, models, MCP, plugins
├── agents/
│   └── skills/
│       └── hm-install/    # Custom skill: install packages via home-manager
│           └── SKILL.md
├── nvim/
│   └── lua/               # Neovim lua configs (opts, vars, keys, plugins)
├── README.md
└── LICENSE
```

## AI Agent Setup

Both Claude Code and OpenCode are configured via the [nix-agent-wire](https://github.com/srid/nix-agent-wire) convention:

- **`nix-agent-wire`** — provides `programs.claude-code` home-manager module
- **`juspay/AI`** — provides `programs.opencode` module + shared skills in `.agents/`
- **`./agents/`** — local custom skills, wired into both tools

Skills from `juspay/AI`: cargo-watch, code-review, nix-ci, nix-flake, nix-haskell, nix-health, nix-justfile, nix-rust-leptos, vhs.

Custom skills: hm-install (ensures all packages are installed via home-manager).

To add a new skill for both tools, create `agents/skills/<name>/SKILL.md` and run `hms` (alias for `home-manager switch --flake ~/.config/home-manager --impure`).

## Updating

```bash
# Update flake inputs
nix flake update

# Apply changes
hms
```

To update only AI-related inputs:
```bash
nix flake update nix-agent-wire juspay-AI
```

## Supported Platforms

- `aarch64-darwin` (Apple Silicon Mac)
- `x86_64-darwin` (Intel Mac)
- `x86_64-linux`
- `aarch64-linux`

## License

See [LICENSE](LICENSE) file.
