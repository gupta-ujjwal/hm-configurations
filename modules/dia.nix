{ config, pkgs, lib, ... }:

let
  appsDir = "${config.home.homeDirectory}/Applications";
  # Unversioned "latest" DMG from diabrowser.com/download. Dia isn't in nixpkgs, and it
  # updates itself (Sparkle), so we only install it when missing instead of pinning a hash.
  dmgUrl = "https://releases.diabrowser.com/release/Dia-latest.dmg";
in
{
  # Dia is macOS-only (Apple Silicon, macOS 14+); no-op elsewhere.
  home.activation.installDia = lib.mkIf pkgs.stdenv.isDarwin (lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ -d "/Applications/Dia.app" ] || [ -d "${appsDir}/Dia.app" ]; then
      :
    elif [ "$(/usr/bin/uname -m)" != "arm64" ]; then
      echo "Skipping Dia install: requires Apple Silicon."
    else
      echo "Installing Dia browser into ${appsDir}..."
      tmp=$(/usr/bin/mktemp -d)
      if ${pkgs.curl}/bin/curl -fL --retry 3 -o "$tmp/Dia.dmg" "${dmgUrl}" \
        && /usr/bin/hdiutil attach -nobrowse -readonly -mountpoint "$tmp/mnt" "$tmp/Dia.dmg" >/dev/null; then
        run mkdir -p "${appsDir}"
        run /usr/bin/ditto "$tmp/mnt/Dia.app" "${appsDir}/Dia.app" \
          || echo "WARNING: Failed to copy Dia.app"
        /usr/bin/hdiutil detach "$tmp/mnt" >/dev/null || true
      else
        echo "WARNING: Could not download/mount Dia; will retry on next switch."
      fi
      rm -rf "$tmp"
    fi
  '');
}
