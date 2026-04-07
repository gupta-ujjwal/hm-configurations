{ config, pkgs, lib, ... }:

let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
  homeDir = config.home.homeDirectory;
  vaultDir = "${homeDir}/obsidian-vault";
  repoUrl = "git@github.com:gupta-ujjwal/obsidian.git";

  # Git sync script for Obsidian notes
  obsidian-sync = pkgs.writeShellScriptBin "obsidian-sync" ''
    set -euo pipefail
    VAULT_DIR="${vaultDir}"

    # Clone if vault doesn't exist yet
    if [ ! -d "$VAULT_DIR/.git" ]; then
      echo "Cloning obsidian vault..."
      ${pkgs.git}/bin/git clone ${repoUrl} "$VAULT_DIR"
      echo "Vault cloned to $VAULT_DIR"
      exit 0
    fi

    cd "$VAULT_DIR"

    # Check for network connectivity
    if ! ${pkgs.git}/bin/git ls-remote --exit-code origin HEAD >/dev/null 2>&1; then
      echo "Cannot reach remote, skipping sync"
      exit 0
    fi

    # Stash any local changes before pulling
    CHANGES=$(${pkgs.git}/bin/git status --porcelain)
    if [ -n "$CHANGES" ]; then
      echo "Staging local changes..."
      ${pkgs.git}/bin/git add -A
      ${pkgs.git}/bin/git commit -m "vault: auto-sync $(date '+%Y-%m-%d %H:%M:%S') from $(hostname -s)" || true
    fi

    # Detect current branch name
    BRANCH=$(${pkgs.git}/bin/git rev-parse --abbrev-ref HEAD)

    # Pull with rebase to keep history clean
    echo "Pulling remote changes..."
    ${pkgs.git}/bin/git pull --rebase --autostash origin main || {
      echo "Rebase conflict detected, attempting merge instead..."
      ${pkgs.git}/bin/git rebase --abort 2>/dev/null || true
      ${pkgs.git}/bin/git pull --no-rebase --autostash origin main || {
        echo "ERROR: Merge conflict. Resolve manually in $VAULT_DIR"
        exit 1
      }
    }

    # Push local commits
    if ${pkgs.git}/bin/git log --oneline origin/main..HEAD | grep -q .; then
      echo "Pushing local changes..."
      ${pkgs.git}/bin/git push origin "$BRANCH":main
    fi

    echo "Sync complete."
  '';

  # Obsidian CLI helper (named 'obs' to avoid conflict with the GUI app binary)
  obsidian-cli = pkgs.writeShellScriptBin "obs" ''
    set -euo pipefail
    VAULT_DIR="${vaultDir}"

    usage() {
      echo "Usage: obs <command> [args]"
      echo ""
      echo "Commands:"
      echo "  sync          Sync vault with GitHub"
      echo "  open          Open Obsidian app (macOS/Linux)"
      echo "  new <name>    Create a new note"
      echo "  search <q>    Search notes by content"
      echo "  list          List all notes"
      echo "  daily         Open/create today's daily note"
      echo "  status        Show git status of vault"
      echo "  log           Show recent sync history"
    }

    if [ $# -eq 0 ]; then
      usage
      exit 1
    fi

    CMD="$1"
    shift

    case "$CMD" in
      sync)
        exec ${obsidian-sync}/bin/obsidian-sync
        ;;
      open)
        if [ "$(uname)" = "Darwin" ]; then
          open -a Obsidian "$VAULT_DIR"
        else
          xdg-open "obsidian://open?path=$VAULT_DIR" 2>/dev/null || ${pkgs.obsidian}/bin/obsidian "$VAULT_DIR" &
        fi
        ;;
      new)
        if [ $# -eq 0 ]; then
          echo "Usage: obsidian new <note-name>"
          exit 1
        fi
        NOTE_NAME="$1"
        NOTE_PATH="$VAULT_DIR/$NOTE_NAME.md"
        mkdir -p "$(dirname "$NOTE_PATH")"
        if [ -f "$NOTE_PATH" ]; then
          echo "Note already exists: $NOTE_PATH"
        else
          cat > "$NOTE_PATH" << NOTEEOF
---
created: $(date '+%Y-%m-%d %H:%M')
tags: []
---

# $NOTE_NAME

NOTEEOF
          echo "Created: $NOTE_PATH"
        fi
        ''${EDITOR:-vim} "$NOTE_PATH"
        ;;
      search)
        if [ $# -eq 0 ]; then
          echo "Usage: obsidian search <query>"
          exit 1
        fi
        ${pkgs.ripgrep}/bin/rg --type md -l -i "$*" "$VAULT_DIR" 2>/dev/null || echo "No results found."
        ;;
      list)
        ${pkgs.findutils}/bin/find "$VAULT_DIR" -name '*.md' -not -path '*/.git/*' -not -path '*/.obsidian/*' | sort | sed "s|$VAULT_DIR/||"
        ;;
      daily)
        TODAY=$(date '+%Y-%m-%d')
        DAILY_DIR="$VAULT_DIR/daily"
        mkdir -p "$DAILY_DIR"
        DAILY_PATH="$DAILY_DIR/$TODAY.md"
        if [ ! -f "$DAILY_PATH" ]; then
          cat > "$DAILY_PATH" << DAILYEOF
---
created: $(date '+%Y-%m-%d %H:%M')
tags: [daily]
---

# $TODAY

## Tasks
- [ ]

## Notes

DAILYEOF
          echo "Created daily note: $DAILY_PATH"
        fi
        ''${EDITOR:-vim} "$DAILY_PATH"
        ;;
      status)
        cd "$VAULT_DIR" && ${pkgs.git}/bin/git status
        ;;
      log)
        cd "$VAULT_DIR" && ${pkgs.git}/bin/git log --oneline -20
        ;;
      *)
        echo "Unknown command: $CMD"
        usage
        exit 1
        ;;
    esac
  '';

in
{
  home.packages = [
    obsidian-sync
    obsidian-cli
    pkgs.obsidian  # GUI app
  ];

  # Auto-sync service: Linux (systemd timer)
  systemd.user.services.obsidian-sync = lib.mkIf isLinux {
    Unit = {
      Description = "Obsidian vault git sync";
      After = [ "network-online.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${obsidian-sync}/bin/obsidian-sync";
      StandardOutput = "append:${homeDir}/.local/share/obsidian/sync.log";
      StandardError = "append:${homeDir}/.local/share/obsidian/sync.log";
    };
  };

  systemd.user.timers.obsidian-sync = lib.mkIf isLinux {
    Unit.Description = "Obsidian vault sync timer";
    Timer = {
      OnCalendar = "*:0/10";  # Every 10 minutes
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };

  # Auto-sync service: macOS (launchd)
  launchd.agents.obsidian-sync = lib.mkIf isDarwin {
    enable = true;
    config = {
      ProgramArguments = [ "${obsidian-sync}/bin/obsidian-sync" ];
      Label = "com.obsidian.vault-sync";
      StartInterval = 600;  # Every 10 minutes
      RunAtLoad = true;
      StandardOutPath = "${homeDir}/.local/share/obsidian/sync.log";
      StandardErrorPath = "${homeDir}/.local/share/obsidian/sync.log";
      EnvironmentVariables = {
        PATH = "${pkgs.git}/bin:${pkgs.openssh}/bin:/usr/bin:/bin";
        HOME = homeDir;
      };
    };
  };

  # Ensure data directory, clone vault, and write gitignore on activation
  home.activation.setupObsidianVault = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p ${homeDir}/.local/share/obsidian
    if [ ! -d "${vaultDir}/.git" ]; then
      # Remove any stale directory so clone can succeed
      rm -rf "${vaultDir}"
      echo "Cloning Obsidian vault from GitHub..."
      ${pkgs.git}/bin/git clone ${repoUrl} "${vaultDir}" || {
        echo "WARNING: Could not clone vault. Creating empty vault — run 'obs sync' after creating the GitHub repo."
        mkdir -p "${vaultDir}"
        cd "${vaultDir}"
        ${pkgs.git}/bin/git init
        ${pkgs.git}/bin/git remote add origin ${repoUrl}
      }
    fi

    # Write .gitignore for Obsidian workspace files
    mkdir -p "${vaultDir}/.obsidian"
    cat > "${vaultDir}/.obsidian/.gitignore" << 'GITIGNORE'
    workspace.json
    workspace-mobile.json
    .obsidian-git-isomorphic-git-data
    GITIGNORE
  '';
}
