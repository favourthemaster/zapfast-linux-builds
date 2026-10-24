#!/usr/bin/env bash
# Installs the latest ZapFast build from favourthemaster/zapfast-linux-builds.
#
# It only replaces the program itself and its launcher. Your settings, local
# window state and the linked WhatsApp session (~/.config/zapfast,
# ~/.local/share/zapfast, ~/.local/state/zapfast) are never touched, so you do
# not have to link your phone again.
set -euo pipefail

REPO="${ZAPFAST_REPO:-favourthemaster/zapfast-linux-builds}"
BIN_DIR="${HOME}/.local/bin"
APP_DIR="${HOME}/.local/share/applications"
ICON_DIR="${HOME}/.local/share/icons/hicolor/scalable/apps"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "==> Finding the latest release of ${REPO}"
url=$(curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" |
  grep -o '"browser_download_url": *"[^"]*ubuntu22.04-x86_64.tar.gz"' |
  head -n1 | sed 's/.*"\(https[^"]*\)"/\1/')
if [ -z "$url" ]; then
  echo "No release asset found. Run the workflow once, then try again." >&2
  exit 1
fi

echo "==> Downloading ${url##*/}"
curl -fsSL "$url" -o "$TMP/zapfast.tar.gz"
tar -xzf "$TMP/zapfast.tar.gz" -C "$TMP"
pkg="$TMP/$(basename "$url" .tar.gz)"

echo "==> Installing the binary to ${BIN_DIR}/zapfast"
mkdir -p "$BIN_DIR"
install -m 755 "$pkg/zapfast" "$BIN_DIR/zapfast.new"
mv "$BIN_DIR/zapfast.new" "$BIN_DIR/zapfast"

echo "==> Installing the launcher and icon"
mkdir -p "$APP_DIR" "$ICON_DIR"
cat > "$APP_DIR/zapfast.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=ZapFast
GenericName=WhatsApp Client
Comment=A native WhatsApp client
Exec=zapfast
Icon=zapfast
Terminal=false
Categories=Network;InstantMessaging;Chat;
Keywords=whatsapp;chat;messaging;
StartupWMClass=zapfast
EOF
if [ -f "$pkg/zapfast.svg" ]; then
  install -m 644 "$pkg/zapfast.svg" "$ICON_DIR/zapfast.svg"
fi
command -v update-desktop-database >/dev/null 2>&1 && update-desktop-database "$APP_DIR" >/dev/null 2>&1 || true
command -v gtk-update-icon-cache >/dev/null 2>&1 && gtk-update-icon-cache -q "$HOME/.local/share/icons/hicolor" >/dev/null 2>&1 || true

echo "==> Installed: $("$BIN_DIR/zapfast" --version)"
echo "    Your existing session and settings were left in place."
