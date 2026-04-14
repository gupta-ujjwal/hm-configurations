#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/gupta-ujjwal/hm-configurations.git"
CONFIG_DIR="${HOME}/.config/home-manager"

# Detect system
case "$(uname -s)-$(uname -m)" in
  Darwin-arm64)  NIX_SYSTEM="aarch64-darwin" ;;
  Darwin-x86_64) NIX_SYSTEM="x86_64-darwin" ;;
  Linux-x86_64)  NIX_SYSTEM="x86_64-linux" ;;
  Linux-aarch64) NIX_SYSTEM="aarch64-linux" ;;
  *) echo "Unsupported platform: $(uname -s)-$(uname -m)" && exit 1 ;;
esac

echo "Detected system: ${NIX_SYSTEM}"
echo "User: ${USER}"
echo "Home: ${HOME}"

# Check nix is installed
if ! command -v nix &>/dev/null; then
  echo "Error: Nix is not installed."
  echo "Install it with: curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install"
  exit 1
fi

# Clone or update the repo
if [ -d "${CONFIG_DIR}/.git" ]; then
  echo "Updating existing config at ${CONFIG_DIR}..."
  git -C "${CONFIG_DIR}" pull --rebase
else
  echo "Cloning config to ${CONFIG_DIR}..."
  mkdir -p "$(dirname "${CONFIG_DIR}")"
  git clone "${REPO_URL}" "${CONFIG_DIR}"
fi

# Run home-manager switch
echo "Applying home-manager configuration..."
export NIX_SYSTEM
nix run "${CONFIG_DIR}#hm" -- switch --flake "${CONFIG_DIR}" --impure

echo ""
echo "Bootstrap complete! Restart your shell or run: source ~/.zshrc"
