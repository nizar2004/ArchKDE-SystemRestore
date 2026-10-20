#!/usr/bin/env bash
#
# Nizar Restore — Arch / KDE Plasma
# Restores the custom fastfetch config, the Ghostty terminal theme,
# and persists the OS install date so the fastfetch "OS Age" survives reinstalls.
#
# Usage:
#   ./install.sh            # restore everything
#   ./install.sh --no-deps  # skip package installation
#   ./install.sh --help     # show help
#
set -euo pipefail

# ---------- config ----------
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_SRC="$REPO_DIR/configs"
DATE_SRC="$REPO_DIR/os-install-date"

FASTFETCH_DIR="$HOME/.config/fastfetch"
GHOSTTY_DIR="$HOME/.config/ghostty"
STATE_DIR="$HOME/.local/state/nizar-restore"
DATE_STATE="$STATE_DIR/os-install-date"

INSTALL_PKGS=true
[[ "${1:-}" == "--no-deps" ]] && INSTALL_PKGS=false
[[ "${1:-}" == "--help" || "${1:-}" == "-h" ]] && { sed -n '2,11p' "$0"; exit 0; }

# ---------- helpers ----------
info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
ok()   { printf '\033[1;32m ✓ \033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m !  \033[0m %s\n' "$*"; }
err()  { printf '\033[1;31m ✗ \033[0m %s\n' "$*" >&2; }

# Need a package manager helper that works with or without pkexec/sudo.
as_root() {
  if [ "$(id -u)" -eq 0 ]; then "$@"
  elif command -v sudo >/dev/null 2>&1; then sudo "$@"
  elif command -v pkexec >/dev/null 2>&1; then pkexec "$@"
  else err "No way to run as root (need sudo or pkexec)."; exit 1; fi
}

# ---------- 1. dependencies ----------
if $INSTALL_PKGS; then
  missing=()
  command -v fastfetch >/dev/null 2>&1 || missing+=("fastfetch")
  command -v ghostty  >/dev/null 2>&1 || missing+=("ghostty")

  if [ ${#missing[@]} -gt 0 ]; then
    info "Installing missing packages: ${missing[*]}"
    if command -v pacman >/dev/null 2>&1; then
      as_root pacman -S --noconfirm "${missing[@]}"
    elif command -v apt >/dev/null 2>&1; then
      as_root apt-get update && as_root apt-get install -y "${missing[@]}"
    else
      warn "Could not detect a package manager. Install manually: ${missing[*]}"
    fi
  else
    ok "fastfetch and ghostty are already installed"
  fi
fi

# ---------- 2. fastfetch ----------
info "Restoring fastfetch config"
mkdir -p "$FASTFETCH_DIR"
if [ -f "$FASTFETCH_DIR/config.jsonc" ]; then
  cp -f "$FASTFETCH_DIR/config.jsonc" "$FASTFETCH_DIR/config.jsonc.bak"
  ok "Backed up old fastfetch config to config.jsonc.bak"
fi
cp -f "$CONFIG_SRC/fastfetch-config.jsonc" "$FASTFETCH_DIR/config.jsonc"
ok "fastfetch config restored -> $FASTFETCH_DIR/config.jsonc"

# ---------- 3. ghostty ----------
info "Restoring Ghostty theme"
mkdir -p "$GHOSTTY_DIR"
if [ -f "$GHOSTTY_DIR/config" ]; then
  cp -f "$GHOSTTY_DIR/config" "$GHOSTTY_DIR/config.bak"
  ok "Backed up old Ghostty config to config.bak"
fi
cp -f "$CONFIG_SRC/ghostty-config" "$GHOSTTY_DIR/config"
ok "Ghostty theme restored -> $GHOSTTY_DIR/config"

# ---------- 4. OS install date (survives reinstall) ----------
info "Persisting OS install date"
mkdir -p "$STATE_DIR"

if [ -s "$DATE_STATE" ]; then
  INSTALL_DATE="$(cat "$DATE_STATE")"
  ok "Using existing install date (state file)"
elif [ -s "$DATE_SRC" ]; then
  INSTALL_DATE="$(cat "$DATE_SRC")"
  printf '%s\n' "$INSTALL_DATE" > "$DATE_STATE"
  ok "Restored install date from repo (previous install)"
else
  INSTALL_DATE="$(stat -c %W / 2>/dev/null || stat -f %B / 2>/dev/null)"
  printf '%s\n' "$INSTALL_DATE" > "$DATE_STATE"
  printf '%s\n' "$INSTALL_DATE" > "$DATE_SRC"
  ok "Recorded current install date"
fi

# Keep the repo's copy in sync so a fresh clone restores it later.
if [ "$INSTALL_DATE" != "$(cat "$DATE_SRC" 2>/dev/null || true)" ]; then
  printf '%s\n' "$INSTALL_DATE" > "$DATE_SRC"
fi

AGE_DAYS=$(( ( $(date +%s) - INSTALL_DATE ) / 86400 ))
AGE_HOURS=$(( ( $(date +%s) - INSTALL_DATE ) / 3600 ))
if [ "$AGE_DAYS" -eq 0 ]; then AGE_STR="${AGE_HOURS} hours"; else AGE_STR="${AGE_DAYS} days"; fi
ok "OS Age will show: $AGE_STR"

# ---------- done ----------
echo
printf '\033[1;32mAll done!\033[0m Run \033[1mfastfetch\033[0m to verify your setup.\n'
echo "Backups saved as *.bak in the config folders."
