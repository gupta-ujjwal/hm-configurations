{ config, pkgs, ... }:

# Daily Brief — a systemd user timer that builds the brief and pushes it to
# GitHub Pages each morning. The heavy lifting lives in the project repo
# (automation/run_daily.sh); this module only schedules it.
let
  repo = "${config.home.homeDirectory}/juspay/Playground/daily-brief";
  runner = "${repo}/automation/run_daily.sh";
in
{
  systemd.user.services.daily-brief = {
    Unit.Description = "Build & publish the Daily Brief to GitHub Pages";
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash ${runner}";
      WorkingDirectory = repo;
      # `claude` lives in the home profile; the rest come from the nix store.
      Environment = [
        "PATH=${pkgs.lib.makeBinPath [ pkgs.bash pkgs.git pkgs.python3 pkgs.coreutils ]}:${config.home.homeDirectory}/.nix-profile/bin:/usr/bin:/bin"
      ];
    };
  };

  systemd.user.timers.daily-brief = {
    Unit.Description = "Schedule the Daily Brief build";
    Timer = {
      OnCalendar = "*-*-* 08:00:00";   # daily at 08:00 local time
      Persistent = true;               # catch up a missed run on next start
    };
    Install.WantedBy = [ "timers.target" ];
  };
}
