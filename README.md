# hm-configurations

This repository contains basic setup and configurations for various tools and applications, aiming to make the setup process smoother for users. The following tools are covered in this configuration setup:

1. **nvim**: Neovim text editor configuration.
2. **mysql**: MySQL database configuration.
3. **htop/btop**: Interactive system monitoring tools.
4. **git**: Git version control configuration.
5. **stack**: Haskell development tool configuration.
6. **redis**: Redis key-value store configuration.
7. **tmux**: Terminal multiplexer configuration.

## Installation

To use these configurations, follow these steps:

1. Create the necessary directory for Home Manager configurations:
   ```mkdir ~/.config/home-manager```
   ```cd ~/.config/home-manager```
2. Clone the repository and move the downloaded configurations into the correct directory: : 
   ```git clone https://github.com/gupta-ujjwal/hm-configurations.git```
   ```mv -r ./hm-configurations ./```
3. Update the `username` and `homeDirectory` settings in the `home.nix` file to match your system.
4. Update the `systemConfiguration` in the `flake.nix` file as needed.
5. Activate the new Home Manager configuration:
   ```nix run nixpkgs#home-manager -- switch```
6. For the Neovim configuration, copy the Lua files:
   ```cp -r ./nvim/lua ../../nvim```
