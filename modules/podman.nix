{ config, pkgs, lib, ... }:

# Rootless Podman on Linux (replaces Colima, whose VM only makes sense on macOS),
# with a Docker-compatible API socket so `docker` / `docker compose` keep working.
let
  podman = config.services.podman.package;
in
lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
  services.podman.enable = true;

  # Rootless podman needs setuid newuidmap/newgidmap. Ubuntu would get these from
  # the `uidmap` apt package; instead, mirror NixOS: copy them from the Nix store
  # into a suid-capable tmpfs at /run/wrappers/bin on every boot.
  my.systemSetup.units."hm-wrappers.service" = pkgs.writeText "hm-wrappers.service" ''
    [Unit]
    Description=setuid wrappers for Nix-provided binaries (newuidmap/newgidmap)
    DefaultDependencies=no
    After=local-fs.target
    Before=multi-user.target

    [Service]
    Type=oneshot
    RemainAfterExit=yes
    ExecStart=${pkgs.writeShellScript "hm-wrappers" ''
      set -eu
      PATH=${lib.makeBinPath [ pkgs.coreutils pkgs.util-linux ]}
      mkdir -p /run/wrappers
      mountpoint -q /run/wrappers || mount -t tmpfs -o mode=755,nodev tmpfs /run/wrappers
      mkdir -p /run/wrappers/bin
      for b in newuidmap newgidmap; do
        install -o root -g root -m 4755 ${pkgs.shadow}/bin/$b /run/wrappers/bin/$b
      done
    ''}

    [Install]
    WantedBy=multi-user.target
  '';

  home.sessionPath = [ "/run/wrappers/bin" ];

  # Docker-API socket (socket-activated, exits when idle).
  systemd.user.sockets.podman = {
    Unit.Description = "Podman API socket";
    Socket = {
      ListenStream = "%t/podman/podman.sock";
      SocketMode = "0660";
    };
    Install.WantedBy = [ "sockets.target" ];
  };
  systemd.user.services.podman = {
    Unit = {
      Description = "Podman API service";
      Requires = [ "podman.socket" ];
      After = [ "podman.socket" ];
    };
    Service = {
      Type = "exec";
      KillMode = "process";
      Delegate = true;
      Environment = [ "PATH=/run/wrappers/bin:/usr/bin:/bin" ];
      ExecStart = "${podman}/bin/podman --log-level=info system service";
    };
  };

  home.sessionVariables.DOCKER_HOST = "unix://$XDG_RUNTIME_DIR/podman/podman.sock";
}
