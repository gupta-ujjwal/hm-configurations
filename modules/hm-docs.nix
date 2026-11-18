{ config, pkgs, lib, ... }:

# Serves this repo's index.html (HM help guide) on :9999.
# Previously started from zsh init, which killed/restarted it on every new shell.
let
  repo = "${config.home.homeDirectory}/.config/home-manager";
  cmd = [ "${pkgs.python3}/bin/python3" "-m" "http.server" "9999" "--directory" repo ];
in
{
  systemd.user.services.hm-docs = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
    Unit.Description = "Home Manager help guide (http://localhost:9999)";
    Service = {
      ExecStart = lib.escapeShellArgs cmd;
      Restart = "on-failure";
    };
    Install.WantedBy = [ "default.target" ];
  };

  launchd.agents.hm-docs = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
    enable = true;
    config = {
      ProgramArguments = cmd;
      RunAtLoad = true;
      KeepAlive = true;
    };
  };
}
