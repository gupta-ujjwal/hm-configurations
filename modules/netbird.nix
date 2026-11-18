{ config, pkgs, lib, ... }:

# NetBird needs root (WireGuard interface, /var/run/netbird, /var/log/netbird),
# so on Linux the daemon is a *system* unit installed via hm-system-setup.
# The CLI (`netbird up/status`) stays in the user profile.
let
  cfg = config.my.netbird;
in
{
  options.my.netbird.enable = lib.mkEnableOption "the NetBird VPN client" // { default = true; };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.netbird ];

    my.systemSetup.units = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
      "netbird.service" = pkgs.writeText "netbird.service" ''
        [Unit]
        Description=NetBird mesh VPN client
        Wants=network-online.target
        After=network-online.target

        [Service]
        ExecStart=${pkgs.netbird}/bin/netbird service run --log-file console --log-level info
        Restart=on-failure
        RestartSec=10

        [Install]
        WantedBy=multi-user.target
      '';
    };
  };
}
