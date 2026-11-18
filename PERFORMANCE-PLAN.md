# Home Server + Daily Driver — Performance Plan

**Machine:** Asus X510UNR (`ujjwal-gupta-X510UNR`) · i7-8550U (4C/8T) · 7 GB RAM · 447 GB SSD · MX150 (on-demand) · Ubuntu 26.04 · always on AC
**Goal:** reliable 24/7 home server (kolu, redis, VPN, timers) that stays fast for browsing.
**Main constraint:** RAM (~3 GB used + 1.1 GB in swap at idle).

## Principles

1. **Home Manager is the only source of truth.** No hand-edited `/etc`, no `apt install`, no ad-hoc `systemctl`.
2. **Generic vs host-specific.** Generic improvements apply on every machine. Server behaviour is opt-in via
   `my.homeServer.enable`, set only in `hosts/x510unr.nix`.
3. **Root-level config is still declared in HM.** Modules add to `my.systemSetup.{units,etcFiles,disabledServices,extraSteps}`;
   HM builds one idempotent `hm-system-setup` script. `hms` warns when it's out of date → run `sudo hm-system-setup`.
   Removing something from the config rolls it back on the next run.

## Layout

| File | Scope | What |
|---|---|---|
| `flake.nix` | — | single `pkgs` import (unfree), `nix-index-database` input, `hosts` map → `"$USER@<hostname>"` configs |
| `hosts/x510unr.nix` | host | `my.homeServer` on, battery limit 80 %, zram 50 % |
| `modules/system-setup.nix` | generic | framework that generates `hm-system-setup` |
| `modules/home-server.nix` | host flag | stay-awake inhibitor, no AC idle-suspend, linger, zram, battery limit, disable/mask services |
| `modules/netbird.nix` | generic | NetBird CLI + **root** system daemon |
| `modules/podman.nix` | generic (Linux) | rootless Podman + Docker-API socket + setuid `newuidmap` wrappers |
| `modules/hm-docs.nix` | generic | help-guide HTTP server as a service |

---

## Phase 1 — Generic HM fixes (every machine) ✅ implemented

- [x] **1.1** NetBird: dropped the crash-looping *user* service (17,572 restarts); daemon is now a root unit via `hm-system-setup`.
- [x] **1.2** `python3 -m http.server 9999` no longer restarted on every zsh start → `hm-docs` user service / launchd agent.
- [x] **1.3** `nix.gc` weekly (`--delete-older-than 14d`) + `services.home-manager.autoExpire` (store is 32 GB).
- [x] **1.4** `targets.genericLinux.enable` on non-NixOS Linux → GPU drivers for Nix Chrome/Obsidian (setup folded into `hm-system-setup`).
- [x] **1.5** Redis: `maxmemory 256mb` (makes `allkeys-lru` work), AOF only.
- [x] **1.6** Colima only on macOS; Linux gets rootless Podman with `DOCKER_HOST` → podman socket.
- [x] **1.7** HM config hygiene:
  - `allowUnfree` moved into the flake's `import nixpkgs` (avoids HM importing nixpkgs twice)
  - prebuilt `nix-index` DB (the DB never existed, so command-not-found was dead)
  - secrets read with `$(<file)` instead of forking `cat` on every shell
  - `stdenv.isLinux/isDarwin` → `stdenv.hostPlatform.*` (deprecation warnings), dropped ignored `programs.opencode.tui`
  - eval time 24 s → 16 s
- [x] **1.8** Update `CLAUDE.md` (still says `aarch64-darwin`; document hosts + `hm-system-setup`).

## Phase 2 — Server profile (`my.homeServer`, this host only) ✅ implemented

- [x] **2.1** `stay-awake` user service: `systemd-inhibit --what=sleep:handle-lid-switch` (lid close + idle suspend blocked; screen still blanks/locks).
- [x] **2.2** dconf `sleep-inactive-ac-type = "nothing"`.
- [x] **2.3** 🔑 `loginctl enable-linger` → user services start at boot without login.
- [x] **2.4** 🔑 zram swap (zstd, 50 % RAM, prio 100); `/swap.img` kept as low-prio overflow; `vm.swappiness=100`, `page-cluster=0`.
- [x] **2.5** 🔑 Battery charge limit 80 % (udev rule + applied immediately).
- [x] **2.6** 🔑 Disable `cups-browsed`, `ModemManager`, `kdump-tools`; mask user `localsearch-3` indexer.
- [x] **2.7** 🔑 Drop kdump's `crashkernel=` boot reservation → **frees 512 MB RAM** after reboot (grub.d snippet + `update-grub`).
- Kolu stays on `0.0.0.0:7681` (decided: LAN access wanted). ⚠️ anyone on the LAN can reach the web terminal.

🔑 = applied by `sudo hm-system-setup`.

## Phase 3 — Apply & verify

```bash
hms                                   # prints the sudo command if system setup is pending
sudo ~/.nix-profile/bin/hm-system-setup   # use the exact store path hms prints

# verify
systemctl --user --failed             # empty
systemctl status netbird hm-zram hm-wrappers
swapon --show                         # /dev/zram0 prio 100, /swap.img prio -1
systemd-inhibit --list | grep home-server
loginctl show-user $USER -p Linger    # yes
cat /sys/class/power_supply/BAT0/charge_control_end_threshold   # 80
redis-cli config get maxmemory        # 268435456
podman run --rm docker.io/library/hello-world && docker ps
# chrome://gpu → hardware accelerated
```

Then **reboot** (needed for the crashkernel change; check `cat /sys/kernel/kexec_crash_size` → 0) **without logging in** and check kolu/redis are reachable from another device.

## Phase 4 — Open items / later

- [ ] Browser: pick one. Drop snap Firefox (+ snapd: ~860 MB RAM, 17 loop mounts) or Chrome. Chrome: enable *Memory Saver*.
      (snap removal is a distro change — could be added as an `extraSteps` entry if wanted.)
- [ ] evolution-data-server services: mask via `maskedUserServices` if GNOME Calendar/Contacts unused.
- [ ] Kolu: if LAN exposure becomes a concern, bind to the NetBird IP instead.
- [ ] Measure after a week: `du -sh /nix/store`, `free -h`, `systemd-analyze`.
