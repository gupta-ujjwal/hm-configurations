# hm-configurations

This repository contains Home Manager configurations using Nix flakes. It provides a declarative setup for development tools and shell environment that can be used across different systems (Linux, macOS) and architectures.

## 🛠️ Configured Tools

### Core Development Tools
- **Neovim**: Text editor with CoC (Conquer of Completion) and Haskell LSP support
- **Tmux**: Terminal multiplexer with vi-mode keybindings
- **Git**: Version control (via git package)
- **Zsh**: Shell with completions, syntax highlighting, and autosuggestions

### Shell Enhancements
- **Starship**: Modern shell prompt
- **fzf**: Fuzzy finder with Zsh integration
- **direnv**: Directory-based environment management with nix-direnv
- **nix-index**: Nix package search

### Development Environments
- **Haskell**: Stack build tool
- **Python**: Python 3.13 with uv package manager
- **Node.js**: Node.js 24
- **Database**: MariaDB, PostgreSQL, Redis

### Container & System Tools
- **Docker**: Docker client
- **Colima**: Docker daemon via VM (macOS)
- **htop/btop**: Interactive system monitors
- **ripgrep**: Fast text search

## 📦 Installation

### Prerequisites
- Nix package manager with flakes enabled
- Supported systems: Linux (x86_64-linux, aarch64-linux) or macOS (x86_64-darwin, aarch64-darwin)

### Setup Steps

1. **Create Home Manager directory:**
   ```bash
   mkdir -p ~/.config/home-manager
   cd ~/.config/home-manager
   ```

2. **Clone this repository:**
   ```bash
   git clone https://github.com/gupta-ujjwal/hm-configurations.git .
   ```

3. **Update configuration:**
   - Edit `flake.nix`: Update `system` (e.g., `x86_64-linux`, `aarch64-darwin`, `x86_64-darwin`) and `username`
   - Edit `home.nix`: Set your `homeDirectory` (e.g., `/home/username` for Linux, `/Users/username` for macOS)

4. **Apply configuration:**
   ```bash
   nix run nixpkgs#home-manager -- switch --flake .
   ```

5. **Neovim Lua files:**
   The Neovim configuration uses Lua files from the `nvim/lua/` directory. These are automatically loaded via the `extraConfig` in `neovim.nix`.

## 📁 Repository Structure

```
.
├── flake.nix           # Nix flake configuration
├── flake.lock          # Locked dependencies
├── home.nix            # Main Home Manager configuration
├── neovim.nix          # Neovim-specific configuration
├── tmux.nix            # Tmux-specific configuration
├── nvim/
│   ├── init.lua        # Neovim initialization
│   ├── coc-settings.json
│   └── lua/
│       ├── opts.lua    # Neovim options
│       ├── vars.lua    # Neovim variables
│       ├── keys.lua    # Keybindings
│       └── plugins.lua # Plugin configurations
├── README.md
└── LICENSE
```

## ⚙️ Configuration Details

### Zsh Configuration
- **History**: 10,000 entries with deduplication
- **Aliases**: 
  - `g` → git
  - `lg` → lazygit
  - `d` → docker
  - `dc` → docker compose
  - `col` → colima

### Neovim Plugins
- vim-airline (status line)
- papercolor-theme & dracula-nvim (themes)
- nerdtree (file explorer)
- telescope.nvim (fuzzy finder)
- vim-fugitive & gv-vim (Git integration)
- vim-commentary (commenting)
- indentLine (indentation guides)
- CoC with Haskell Language Server

### Tmux Settings
- Prefix: `Ctrl-a`
- Base index: 1
- Vi-mode keybindings
- Mouse support enabled
- Custom pane navigation

## 🔄 Updating

To update your configuration after making changes:

```bash
home-manager switch --flake ~/.config/home-manager
```

To update flake inputs (nixpkgs, home-manager):

```bash
nix flake update
home-manager switch --flake ~/.config/home-manager
```

## 📝 License

See [LICENSE](LICENSE) file for details.

## 🤝 Contributing

Feel free to open issues or submit pull requests for improvements!