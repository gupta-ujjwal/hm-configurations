{ config, pkgs, lib, ... }:

# Opt-in "this laptop is also a home server" profile. Enable per-host in hosts/*.nix.
# User-level parts are plain HM; root-level parts go through my.systemSetup.
let
  cfg = config.my.homeServer;
  user = config.home.username;
in
{
  options.my.homeServer = {
    enable = lib.mkEnableOption "always-on home server tweaks";

    batteryChargeLimit = lib.mkOption {
      type = lib.types.nullOr (lib.types.ints.between 20 100);
      default = null;
      example = 80;
      description = "Stop charging at this percentage (laptops that live on AC).";
    };
    battery = lib.mkOption {
      type = lib.types.str;
      default = "BAT0";
      description = "Battery name under /sys/class/power_supply.";
    };

    zram = {
      enable = lib.mkEnableOption "zram swap" // { default = true; };
      percent = lib.mkOption {
        type = lib.types.ints.between 10 150;
        default = 50;
        description = "zram device size as % of RAM. Disk swap is kept as lower-priority overflow.";
      };
    };

    disabledServices = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "cups-browsed.service" "ModemManager.service" "kdump-tools.service" ];
      description = "Distro system services not needed on a server.";
    };

    maskedUserServices = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "localsearch-3.service" ];  # GNOME file indexer: constant CPU/IO
      description = "User services to mask (symlinked to /dev/null).";
    };

    dropCrashKernel = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Remove Ubuntu's kdump `crashkernel=` boot reservation (512 MB on a 4-32 GB box)
        and regenerate grub. Takes effect after a reboot.
      '';
    };
  };

  config = lib.mkIf (cfg.enable && pkgs.stdenv.hostPlatform.isLinux) {
    # ---------- user level ----------

    # Block suspend (idle *and* lid close) for as long as the user manager runs,
    # which with lingering is "always". Screen blanking/locking is unaffected.
    systemd.user.services.stay-awake = {
      Unit.Description = "Keep the home server awake (block sleep and lid-switch)";
      Service = {
        ExecStart = lib.escapeShellArgs [
          "${pkgs.systemd}/bin/systemd-inhibit"
          "--what=sleep:handle-lid-switch"
          "--who=home-server"
          "--why=Always-on home server"
          "--mode=block"
          "${pkgs.coreutils}/bin/sleep" "infinity"
        ];
        Restart = "always";
      };
      Install.WantedBy = [ "default.target" ];
    };

    # Belt and braces: don't let GNOME even try to idle-suspend on AC.
    dconf.settings."org/gnome/settings-daemon/plugins/power" = {
      sleep-inactive-ac-type = "nothing";
    };

    xdg.configFile = lib.listToAttrs (map (s:
      lib.nameValuePair "systemd/user/${s}" { source = config.lib.file.mkOutOfStoreSymlink "/dev/null"; }
    ) cfg.maskedUserServices);

    # ---------- root level (sudo hm-system-setup) ----------

    my.systemSetup = {
      disabledServices = cfg.disabledServices;

      # Start user services (kolu, redis, timers, stay-awake) at boot, without a login.
      extraSteps."10-linger" = "loginctl enable-linger ${user}";

      units = lib.mkIf cfg.zram.enable {
        "hm-zram.service" = pkgs.writeText "hm-zram.service" ''
          [Unit]
          Description=Compressed RAM swap (zram, ${toString cfg.zram.percent}% of RAM)
          DefaultDependencies=no
          Before=swap.target
          After=systemd-modules-load.service

          [Service]
          Type=oneshot
          RemainAfterExit=yes
          ExecStart=${pkgs.writeShellScript "hm-zram-start" ''
            set -eu
            PATH=${lib.makeBinPath [ pkgs.coreutils pkgs.gawk pkgs.gnugrep pkgs.util-linux ]}:/usr/sbin:/sbin
            [ -e /dev/zram0 ] && swapon --show=NAME --noheadings | grep -q zram0 && exit 0
            modprobe zram
            kb=$(awk '/MemTotal/ { print int($2 * ${toString cfg.zram.percent} / 100) }' /proc/meminfo)
            zramctl --reset /dev/zram0 2>/dev/null || true
            zramctl /dev/zram0 --algorithm zstd --size "''${kb}K"
            mkswap -L zram0 /dev/zram0
            swapon --priority 100 /dev/zram0
          ''}
          ExecStop=${pkgs.writeShellScript "hm-zram-stop" ''
            PATH=${lib.makeBinPath [ pkgs.util-linux ]}
            swapoff /dev/zram0 || true
            zramctl --reset /dev/zram0 || true
          ''}

          [Install]
          WantedBy=swap.target
        '';
      };

      etcFiles = lib.mkMerge [
        (lib.mkIf cfg.zram.enable {
          # zram is cheap to swap to: swap earlier, no readahead clustering.
          "sysctl.d/90-hm-zram.conf" = pkgs.writeText "90-hm-zram.conf" ''
            vm.swappiness = 100
            vm.page-cluster = 0
          '';
        })
        (lib.mkIf cfg.dropCrashKernel {
          # grub-mkconfig sources grub.d/*.cfg in order; "zz-" sorts after kdump-tools.cfg.
          "default/grub.d/zz-hm-no-crashkernel.cfg" = pkgs.writeText "zz-hm-no-crashkernel.cfg" ''
            GRUB_CMDLINE_LINUX_DEFAULT="$(echo "$GRUB_CMDLINE_LINUX_DEFAULT" | sed 's/crashkernel=[^ ]*//g')"
          '';
        })
        (lib.mkIf (cfg.batteryChargeLimit != null) {
          "udev/rules.d/90-hm-battery.rules" = pkgs.writeText "90-hm-battery.rules" ''
            ACTION=="add|change", SUBSYSTEM=="power_supply", KERNEL=="${cfg.battery}", ATTR{charge_control_end_threshold}="${toString cfg.batteryChargeLimit}"
          '';
        })
      ];

      # Regenerate grub only when our grub.d snippets changed (added *or* removed).
      extraSteps."30-grub" = ''
        h=$(cat /etc/default/grub.d/zz-hm-* 2>/dev/null | sha256sum)
        if [ "$h" != "$(cat /var/lib/hm-system-setup/grub-hash 2>/dev/null)" ]; then
          update-grub && echo "$h" > /var/lib/hm-system-setup/grub-hash
          echo "grub updated — reboot to apply kernel cmdline changes"
        fi
      '';

      extraSteps."20-apply-now" = ''
        ${lib.optionalString cfg.zram.enable "sysctl -p /etc/sysctl.d/90-hm-zram.conf"}
        ${lib.optionalString (cfg.batteryChargeLimit != null) ''
          echo ${toString cfg.batteryChargeLimit} > /sys/class/power_supply/${cfg.battery}/charge_control_end_threshold || true
        ''}
      '';
    };
  };
}
