{ config, pkgs, lib, ... }:

# Root-level host config, still declared in Home Manager.
#
# HM can't write /etc or manage system units, so modules declare what they need
# here and HM builds one idempotent script, `hm-system-setup` (same approach HM
# uses for targets.genericLinux.gpu). Every `hms` checks whether the applied
# version matches and prints the exact `sudo` command if it doesn't.
#
# The script is declarative: units, /etc files and disabled services that are
# removed from the config are rolled back on the next run.
let
  cfg = config.my.systemSetup;
  stateDir = "/var/lib/hm-system-setup";

  unitDir = pkgs.linkFarm "hm-system-units" (lib.mapAttrs (_: u: u) cfg.units);
  etcDir = pkgs.linkFarm "hm-system-etc" (lib.mapAttrs (_: f: f) cfg.etcFiles);

  unitNames = lib.attrNames cfg.units;
  etcNames = lib.attrNames cfg.etcFiles;

  steps = lib.concatStringsSep "\n" (lib.mapAttrsToList (name: text: ''
    echo "==> ${name}"
    ${text}
  '') cfg.extraSteps);

  script = pkgs.writeShellScriptBin "hm-system-setup" ''
    set -euo pipefail
    export PATH=${lib.makeBinPath [ pkgs.coreutils pkgs.gnugrep pkgs.diffutils ]}:/usr/sbin:/usr/bin:/sbin:/bin
    if [ "$(id -u)" -ne 0 ]; then
      echo "Run as root: sudo $(readlink -f "$0")" >&2
      exit 1
    fi
    mkdir -p ${stateDir}
    touch ${stateDir}/units ${stateDir}/etc ${stateDir}/disabled-services

    # --- /etc files --------------------------------------------------------
    for f in $(cat ${stateDir}/etc); do
      if ! printf '%s\n' ${lib.escapeShellArgs etcNames} | grep -qxF "$f"; then
        echo "removing /etc/$f"; rm -f "/etc/$f"
      fi
    done
    ${lib.concatMapStrings (f: ''
      install -Dm644 ${etcDir}/${f} /etc/${f}
    '') etcNames}
    printf '%s\n' ${lib.escapeShellArgs etcNames} > ${stateDir}/etc

    # --- systemd units -----------------------------------------------------
    for u in $(cat ${stateDir}/units); do
      if ! printf '%s\n' ${lib.escapeShellArgs unitNames} | grep -qxF "$u"; then
        echo "removing unit $u"
        systemctl disable --now "$u" || true
        rm -f "/etc/systemd/system/$u"
      fi
    done
    changed=()
    ${lib.concatMapStrings (u: ''
      if ! cmp -s ${unitDir}/${u} /etc/systemd/system/${u}; then
        install -Dm644 ${unitDir}/${u} /etc/systemd/system/${u}
        changed+=(${u})
      fi
    '') unitNames}
    printf '%s\n' ${lib.escapeShellArgs unitNames} > ${stateDir}/units
    systemctl daemon-reload
    ${lib.concatMapStrings (u: ''
      systemctl enable ${u}
    '') unitNames}
    failed=()
    for u in "''${changed[@]}"; do
      echo "(re)starting $u"
      systemctl restart "$u" || failed+=("$u")
    done

    # --- distro services we don't want ------------------------------------
    for s in $(cat ${stateDir}/disabled-services); do
      if ! printf '%s\n' ${lib.escapeShellArgs cfg.disabledServices} | grep -qxF "$s"; then
        echo "re-enabling $s"; systemctl enable --now "$s" || true
      fi
    done
    ${lib.concatMapStrings (s: ''
      systemctl disable --now ${s} 2>/dev/null || true
    '') cfg.disabledServices}
    printf '%s\n' ${lib.escapeShellArgs cfg.disabledServices} > ${stateDir}/disabled-services

    # --- one-off steps ----------------------------------------------------
    ${steps}

    # Keep the applied version (and every store path its units reference)
    # alive across `nix-collect-garbage`, even if HM moves on before re-running.
    ln -sfn "$(readlink -f "$0" | xargs dirname | xargs dirname)" /nix/var/nix/gcroots/hm-system-setup
    if [ ''${#failed[@]} -gt 0 ]; then
      echo "System setup finished with failing units: ''${failed[*]}" >&2
      echo "Inspect with: systemctl status ''${failed[*]}" >&2
      exit 1
    fi
    echo "$(readlink -f "$0")" > ${stateDir}/applied
    echo "System setup applied."
  '';
in
{
  options.my.systemSetup = {
    units = lib.mkOption {
      type = lib.types.attrsOf lib.types.path;
      default = { };
      description = "System unit files to install into /etc/systemd/system and enable.";
    };
    etcFiles = lib.mkOption {
      type = lib.types.attrsOf lib.types.path;
      default = { };
      description = "Files to install under /etc (key is the path relative to /etc).";
    };
    disabledServices = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Distro system services to disable (re-enabled if removed from this list).";
    };
    extraSteps = lib.mkOption {
      type = lib.types.attrsOf lib.types.lines;
      default = { };
      description = "Idempotent root shell snippets, run in name order.";
    };
  };

  config = lib.mkIf (pkgs.stdenv.hostPlatform.isLinux && (cfg.units != { } || cfg.etcFiles != { } || cfg.disabledServices != [ ] || cfg.extraSteps != { })) {
    home.packages = [ script ];

    home.activation.checkSystemSetup = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ "$(cat ${stateDir}/applied 2>/dev/null)" != "${script}/bin/hm-system-setup" ]; then
        warnEcho "System-level config changed and is not applied yet. Run:"
        warnEcho "  sudo ${script}/bin/hm-system-setup"
      fi
    '';
  };
}
