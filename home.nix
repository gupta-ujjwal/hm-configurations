{ config, pkgs, username, ... }:

{
  home = {
    username = username;
    homeDirectory = "/Users/Ujjwal.gupta";
    stateVersion = "22.11";
  };

  programs.home-manager.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.starship.enable = true;

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

    initExtra = ''
      # Add Claude Code to PATH
      export PATH="/Users/Ujjwal.gupta/Downloads/google-cloud-sdk/bin:/Users/Ujjwal.gupta/.nix-profile/bin:/nix/var/nix/profiles/default/bin:/usr/local/bin:/System/Cryptexes/App/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin:/Library/TeX/texbin:/etc/profiles/per-user/Ujjwal.gupta/bin:/nix/var/nix/profiles/system/sw/bin"

      export ANTHROPIC_BASE_URL="https://grid.ai.juspay.net/"
      export ANTHROPIC_AUTH_TOKEN="sk-9JZFkFqdTJwyNnntpGqFRA"
      export ANTHROPIC_MODEL="glm-latest"

      export VERTEX_PROJECT_ID="dev-ai-gamma"
      export VERTEX_MODEL="claude-sonnet-4@20250514"
      export VERTEX=1
      export VERTEX_REGION="us-east5"
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
      redis-start = "launchctl load ~/Library/LaunchAgents/org.redis.redis-server.plist";
      redis-stop = "launchctl unload ~/Library/LaunchAgents/org.redis.redis-server.plist";
      redis-restart = "launchctl unload ~/Library/LaunchAgents/org.redis.redis-server.plist && launchctl load ~/Library/LaunchAgents/org.redis.redis-server.plist";
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
    mariadb
    htop
    btop
    git
    stack
    redis
    tmux
    tmate
    python313
    postgresql
    uv
    docker   # docker client
    colima   # docker daemon via VM
    ripgrep
    nodejs_24  # includes xyne-cli
  ];

  # Optional: ensure Colima is on PATH
  home.sessionPath = [ "${pkgs.colima}/bin" ];

  # Redis service configuration for macOS using launchd
  launchd.agents.redis = {
    enable = true;
    config = {
      ProgramArguments = [
        "${pkgs.redis}/bin/redis-server"
        "${config.home.homeDirectory}/.config/redis/redis.conf"
      ];
      Label = "org.redis.redis-server";
      RunAtLoad = true;
      KeepAlive = true;
      StandardOutPath = "${config.home.homeDirectory}/.local/share/redis/redis.log";
      StandardErrorPath = "${config.home.homeDirectory}/.local/share/redis/redis.log";
      WorkingDirectory = "${config.home.homeDirectory}/.local/share/redis";
    };
  };

  # Redis configuration file
  home.file.".config/redis/redis.conf".text = ''
    # Redis configuration for home manager on macOS
    port 6379
    bind 127.0.0.1
    timeout 0
    tcp-keepalive 300
    daemonize no
    supervised no
    pidfile ${config.home.homeDirectory}/.local/share/redis/redis.pid
    loglevel notice
    logfile ${config.home.homeDirectory}/.local/share/redis/redis.log
    databases 16
    save 900 1
    save 300 10
    save 60 10000
    stop-writes-on-bgsave-error yes
    rdbcompression yes
    rdbchecksum yes
    dbfilename dump.rdb
    dir ${config.home.homeDirectory}/.local/share/redis
    maxmemory-policy allkeys-lru
    appendonly yes
    appendfilename "appendonly.aof"
    appendfsync everysec
    no-appendfsync-on-rewrite no
    auto-aof-rewrite-percentage 100
    auto-aof-rewrite-min-size 64mb
  '';

  # Create Redis data directory
  home.activation.createRedisDir = ''
    mkdir -p ${config.home.homeDirectory}/.local/share/redis
    chmod 755 ${config.home.homeDirectory}/.local/share/redis
  '';




}

