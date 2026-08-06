{ config, pkgs, system, username, nix-agent-wire, juspay-AI, kolu, euler-workspace, ... }:

{
  nixpkgs.config.allowUnfree = true;

  imports = [
    nix-agent-wire.homeModules.opencode
    nix-agent-wire.homeModules.claude-code
  ];

  home = {
    username = username;
    homeDirectory = if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}";
    stateVersion = "22.11";
  };

  programs.home-manager.enable = true;

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
    '';

    initContent = ''
      # export ANTHROPIC_BASE_URL="https://grid.ai.juspay.net/"
      # export ANTHROPIC_MODEL="glm-latest"
      
      # Load ANTHROPIC_AUTH_TOKEN from local file if it exists
      if [[ -f ~/.config/secrets/anthropic_token ]]; then
        export ANTHROPIC_AUTH_TOKEN=$(cat ~/.config/secrets/anthropic_token)
      fi

      # Load JUSPAY_API_KEY from local file if it exists
      if [[ -f ~/.config/secrets/juspay_api_key ]]; then
        export JUSPAY_API_KEY=$(cat ~/.config/secrets/juspay_api_key)
      fi

      # Start HTTP server for home-manager documentation on port 9999
      # Kill any existing server on port 9999 first
      pkill -f "python3 -m http.server 9999" > /dev/null 2>&1
      # Start new server
      (cd ~/.config/home-manager && python3 -m http.server 9999 > /dev/null 2>&1 &)
      # Display message to user
      echo "📚 Home Manager Help Guide running at http://localhost:9999"
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
      redis-start = if pkgs.stdenv.isDarwin
        then "launchctl load ~/Library/LaunchAgents/org.redis.redis-server.plist"
        else "systemctl --user start redis";
      redis-stop = if pkgs.stdenv.isDarwin
        then "launchctl unload ~/Library/LaunchAgents/org.redis.redis-server.plist"
        else "systemctl --user stop redis";
      redis-restart = if pkgs.stdenv.isDarwin
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

  home.packages = with pkgs; [
    ngrok
    mariadb
    htop
    btop
    git
    stack
    redis
    tmux
    tmate
    python313
    postgresql_17
    pnpm
    uv
    docker   # docker client
    colima   # docker daemon via VM
    lazygit
    ripgrep
    nodejs_24  # includes xyne-cli
    opencode
    netbird
    gh
    nerd-fonts.jetbrains-mono
    kolu.packages.${system}.default  # kolu CLI on PATH (service is wired separately in modules/kolu.nix)
  ];

  # Optional: ensure Colima is on PATH
  home.sessionPath = [
    "${pkgs.colima}/bin"
    "${config.home.homeDirectory}/Downloads/google-cloud-sdk/bin"
  ];


  programs.opencode = {
    enable = true;
    autoWire.dirs = [ (juspay-AI + "/.opencode") (euler-workspace + "/skills") ./agents ];
    settings = import ./modules/opencode-config.nix;
    tui.theme = "one-dark";
    # Single skill pulled from the kolu repo (github:juspay/kolu .agents/skills/kolu).
    skills.kolu = kolu + "/.agents/skills/kolu";
  };

  programs.claude-code = {
    enable = true;
    autoWire.dirs = [ (juspay-AI + "/.claude") (euler-workspace + "/skills") ./agents ];
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

  # Single skill pulled from the kolu repo (github:juspay/kolu .agents/skills/kolu).
  # autoWire on a whole dir would wire all ~40 skills, so wire just this one as a
  # directory symlink (same mechanism nix-agent-wire uses for autoWired skills).
  home.file.".claude/skills/kolu".source = kolu + "/.agents/skills/kolu";

  systemd.user.services.netbird = {
    Unit = {
      Description = "Netbird VPN daemon";
      After = [ "network.target" ];
    };
    Service = {
      ExecStart = "${pkgs.netbird}/bin/netbird service run";
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

}

