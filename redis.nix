{ config, pkgs, lib, ... }:

let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in
{
  # Linux: systemd service
  systemd.user.services.redis = lib.mkIf isLinux {
    Unit = {
      Description = "Redis in-memory data store";
      After = [ "network.target" ];
    };
    Service = {
      ExecStart = "${pkgs.redis}/bin/redis-server ${config.home.homeDirectory}/.config/redis/redis.conf";
      Restart = "on-failure";
      StandardOutput = "append:${config.home.homeDirectory}/.local/share/redis/redis.log";
      StandardError = "append:${config.home.homeDirectory}/.local/share/redis/redis.log";
      WorkingDirectory = "${config.home.homeDirectory}/.local/share/redis";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  # macOS: launchd agent
  launchd.agents.redis = lib.mkIf isDarwin {
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
  home.activation.createRedisDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p ${config.home.homeDirectory}/.local/share/redis
    chmod 755 ${config.home.homeDirectory}/.local/share/redis
  '';
}
