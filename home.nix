{ config, pkgs, lib, system, username, juspay-AI, kolu, ... }:

let
  # Uses the same ~/.config/google-chrome profile the old apt install did.
  # Pin the password store to GNOME keyring so saved passwords (encrypted with
  # the "Chrome Safe Storage" keyring secret) stay readable.
  google-chrome = pkgs.google-chrome.override { commandLineArgs = "--password-store=gnome-libsecret"; };
in
{
  imports = [
    ./modules/autowire/opencode.nix
    ./modules/autowire/claude-code.nix
  ];

  home = {
    username = username;
    homeDirectory = if pkgs.stdenv.hostPlatform.isDarwin then "/Users/${username}" else "/home/${username}";
    stateVersion = "22.11";
  };

  programs.home-manager.enable = true;

  # Non-NixOS Linux (Ubuntu): session/XDG fixes + GPU drivers for Nix GUI apps
  # (Chrome, Obsidian), which otherwise can't find system GL and software-render.
  # One-time root step is folded into `sudo hm-system-setup`.
  targets.genericLinux.enable = lib.mkDefault (pkgs.stdenv.hostPlatform.isLinux && !builtins.pathExists "/etc/NIXOS");
  my.systemSetup.extraSteps."00-gpu-drivers" = lib.mkIf config.targets.genericLinux.gpu.enable
    (lib.getExe config.targets.genericLinux.gpu.setupPackage);

  # Keep the store and HM generations from growing forever.
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
  services.home-manager.autoExpire = {
    enable = true;
    frequency = "weekly";
    timestamp = "-14 days";
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.starship.enable = true;
  
  fonts.fontconfig.enable = true;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    
    history = {
      size = 10000;
      save = 10000;
      path = "$HOME/.zsh_history";
      ignoreDups = true;
      share = true;
    };

    envExtra = ''
      export LANG="en_IN.UTF-8"

      # Ensure Nix is on PATH for non-interactive shells too (e.g. `ssh host cmd`,
      # which sourced only .zshenv, not .zshrc — kolu needs nix-instantiate there).
      if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
        . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
      elif [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
        . "$HOME/.nix-profile/etc/profile.d/nix.sh"
      fi
    '';

    initContent = ''
      # export ANTHROPIC_BASE_URL="https://grid.ai.juspay.net/"
      # export ANTHROPIC_MODEL="glm-latest"
      
      # Load ANTHROPIC_AUTH_TOKEN from local file if it exists
      if [[ -f ~/.config/secrets/anthropic_token ]]; then
        export ANTHROPIC_AUTH_TOKEN=$(<~/.config/secrets/anthropic_token)
      fi

      # Load JUSPAY_API_KEY from local file if it exists
      if [[ -f ~/.config/secrets/juspay_api_key ]]; then
        export JUSPAY_API_KEY=$(<~/.config/secrets/juspay_api_key)
      fi
    '';

    shellAliases = {
      g = "git";
      lg = "lazygit";
      d = "docker";
      dc = "docker compose";
      col = "colima";
      xyne = "npx @xyne/xyne-cli";
      redis-cli = "${pkgs.redis}/bin/redis-cli";
      redis-server = "${pkgs.redis}/bin/redis-server";
      redis-start = if pkgs.stdenv.hostPlatform.isDarwin
        then "launchctl load ~/Library/LaunchAgents/org.redis.redis-server.plist"
        else "systemctl --user start redis";
      redis-stop = if pkgs.stdenv.hostPlatform.isDarwin
        then "launchctl unload ~/Library/LaunchAgents/org.redis.redis-server.plist"
        else "systemctl --user stop redis";
      redis-restart = if pkgs.stdenv.hostPlatform.isDarwin
        then "launchctl unload ~/Library/LaunchAgents/org.redis.redis-server.plist && launchctl load ~/Library/LaunchAgents/org.redis.redis-server.plist"
        else "systemctl --user restart redis";
      hms = "home-manager switch --flake ${config.home.homeDirectory}/.config/home-manager --impure";
      # Obsidian
      os = "obs sync";
      on = "obs new";
      od = "obs daily";
    };
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.nix-index = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.bash.enable = true;

  home.packages = with pkgs; [
    ngrok
    mariadb
    htop
    btop
    git
    stack
    redis
    tmux
    python313
    postgresql_17
    pnpm
    uv
    docker   # docker client (Linux: talks to rootless podman, modules/podman.nix)
    lazygit
    ripgrep
    nodejs_24
    netlify-cli
    opencode
    gh
    nerd-fonts.jetbrains-mono
    kolu.packages.${system}.default  # kolu CLI on PATH (service is wired separately in modules/kolu.nix)
  ] ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
    google-chrome
  ] ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
    colima   # docker daemon via VM (Linux runs containers natively)
  ];

  # GNOME doesn't notice when ~/.nix-profile/share/applications is repointed on
  # switch, so Chrome wouldn't show in app search. ~/.local/share/applications
  # is a real directory GNOME watches.
  home.file.".local/share/applications/google-chrome.desktop" = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
    source = "${google-chrome}/share/applications/google-chrome.desktop";
  };

  home.sessionPath = [
    "${config.home.homeDirectory}/Downloads/google-cloud-sdk/bin"
  ];


  programs.opencode = {
    enable = true;
    autoWire.dirs = [ (juspay-AI + "/.opencode") ./agents ];
    settings = import ./modules/opencode-config.nix;
  };

  programs.claude-code = {
    enable = true;
    autoWire.dirs = [ (juspay-AI + "/.claude") ./agents ];
    # The nixpkgs claude-code wrapper prepends a Nix alsa-lib to LD_LIBRARY_PATH
    # (for the voice feature's audio-capture.node). That var is exported, so every
    # child of `claude` — the Bash tool, MCP servers, and ultimately system Chrome
    # launched by the Playwright MCP — inherits it. That alsa-lib needs GLIBC_2.38
    # while the system glibc is 2.35, so system Chrome crashes on launch.
    # Swapping the alsa-lib input for an empty dir makes the wrapper point
    # LD_LIBRARY_PATH at a nonexistent path (ld.so ignores it), so nothing leaks.
    # Voice still works: audio-capture.node falls back to the system libasound.so.2
    # (this is a non-NixOS host, so /lib/x86_64-linux-gnu/libasound.so.2 exists).
    package = pkgs.claude-code.override { alsa-lib = pkgs.emptyDirectory; };
  };

  # Playwright MCP defaults to /opt/google/chrome/chrome (the old apt install);
  # point it at the home-manager Chrome instead.
  programs.claude-code.settings.env = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
    PLAYWRIGHT_MCP_EXECUTABLE_PATH = "${config.home.profileDirectory}/bin/google-chrome-stable";
  };

}

