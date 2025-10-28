{ config, pkgs, ... }:

{
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