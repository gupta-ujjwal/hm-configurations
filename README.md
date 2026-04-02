# hm-configurations

Declarative Home Manager setup using Nix flakes. Manages development tools, shell environment, AI coding agents, and services — reproducible across machines.

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

## Installation

### Prerequisites
- Nix with flakes enabled
- System: `x86_64-linux` (currently configured)

### Setup

```bash
git clone https://github.com/gupta-ujjwal/hm-configurations.git ~/.config/home-manager
cd ~/.config/home-manager
```

Edit `flake.nix` — update `system` and `username`.
Edit `home.nix` — update `homeDirectory`.

```bash
nix run nixpkgs#home-manager -- switch --flake .
```

## Repository Structure

```
.
├── flake.nix              # Flake inputs: nixpkgs, home-manager, nix-agent-wire, juspay/AI
├── flake.lock
├── home.nix               # Main config: packages, zsh, aliases, agent wiring
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

To add a new skill for both tools, create `agents/skills/<name>/SKILL.md` and run `home-manager switch`.

## Updating

```bash
# Update flake inputs
nix flake update

# Apply changes
home-manager switch --flake ~/.config/home-manager
```

To update only AI-related inputs:
```bash
nix flake update nix-agent-wire juspay-AI
```

## License

See [LICENSE](LICENSE) file.
