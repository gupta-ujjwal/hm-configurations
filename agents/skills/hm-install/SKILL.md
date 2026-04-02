---
name: hm-install
description: Use this when the user asks to install a package, software, tool, or service. Everything must go through home-manager for reproducibility.
---

# Installing packages via home-manager

This user manages their entire system through home-manager at `~/.config/home-manager/`. NEVER install anything via apt, brew, npm -g, pip install, cargo install, or any other imperative method. Everything must be declarative through nix/home-manager.

## Repository structure

```
~/.config/home-manager/
├── flake.nix          # flake inputs and homeConfigurations
├── home.nix           # main config: packages, shell, aliases, imports
├── neovim.nix         # programs.neovim config + plugins
├── tmux.nix           # programs.tmux config
├── tmate.nix          # tmate config
├── redis.nix          # redis service (systemd + launchd) + config file
├── opencode-config.nix # opencode settings (providers, mcp, plugins)
└── agents/            # shared AI agent skills
```

## How to install

### Simple CLI tools (no config needed)

Add to `home.packages` in `home.nix`:

```nix
home.packages = with pkgs; [
  ripgrep
  htop
  jq
  # add new packages here
];
```

### Programs with configuration

If home-manager has a `programs.<name>` module, prefer that over raw `home.packages` — it gives you declarative config management.

```nix
# In home.nix or a dedicated <name>.nix file
programs.foo = {
  enable = true;
  # ... config options
};
```

Check if a module exists: search https://home-manager-options.extranix.com/ or use `nix-mcp` tool.

### When to create a separate .nix file

Create a new `<name>.nix` when the config is more than ~5 lines. Then:

1. Create `~/.config/home-manager/<name>.nix` with the config
2. Add it to the `modules` list in `flake.nix`:
   ```nix
   modules = [ ./home.nix ./neovim.nix ./tmux.nix ./tmate.nix ./redis.nix ./<name>.nix ];
   ```

### Services (daemons)

For services that need to run in background, follow the pattern in `redis.nix`:

- Linux: `systemd.user.services.<name>`
- macOS: `launchd.agents.<name>`
- Use `lib.mkIf pkgs.stdenv.isLinux` / `lib.mkIf pkgs.stdenv.isDarwin` for cross-platform

### Config files

For tools that need config files but don't have a home-manager module:

```nix
home.file.".config/tool/config.toml".text = ''
  # config content
'';
# or from a file in the repo:
home.file.".config/tool/config.toml".source = ./tool-config.toml;
```

### Shell aliases

Add to `programs.zsh.shellAliases` in `home.nix`:

```nix
shellAliases = {
  foo = "foo --some-default-flags";
};
```

## After making changes

Tell the user to run `home-manager switch` to apply. The flake.nix uses `x86_64-linux` as the system.

## Finding packages

Use `nix search nixpkgs#<name>` to find the correct package attribute name. The nixpkgs input tracks `nixos-unstable`.

## Function signature patterns

New `.nix` files should use this pattern:

```nix
{ config, pkgs, lib, ... }:
{
  # config here
}
```

Only add parameters you actually use. Check existing files for reference.
