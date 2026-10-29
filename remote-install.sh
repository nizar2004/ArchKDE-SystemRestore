#!/usr/bin/env bash
#
# ArchKDE-SystemRestore — one-command installer
#
# Run this single command (no git clone needed):
#
#   curl -fsSL https://raw.githubusercontent.com/nizar2004/ArchKDE-SystemRestore/main/remote-install.sh | bash
#
# It downloads the project to ~/.local/share/ArchKDE-SystemRestore (persistent, so the
# `archkde-restore` command keeps working after the download), then runs the bootstrap.
#
set -euo pipefail

REPO="nizar2004/ArchKDE-SystemRestore"
DEST="${XDG_DATA_HOME:-$HOME/.local/share}/ArchKDE-SystemRestore"
GIT_URL="https://github.com/$REPO.git"
ARCHIVE="https://github.com/$REPO/archive/refs/heads/main.tar.gz"

# --- styling (auto-disabled when output isn't a real terminal) ---
if [ -t 1 ]; then
  C=$'\033[1;34m' G=$'\033[1;32m' D=$'\033[0;90m' R=$'\033[0m'
else
  C='' G='' D='' R=''
fi
info() { printf '%s\n' "${C}==>${R} $*"; }
ok()   { printf '%b\n' "${G} \u2713 ${R}$*"; }

for bin in curl tar; do
  command -v "$bin" >/dev/null 2>&1 || { echo "error: '$bin' is required" >&2; exit 1; }
done

info "Fetching ArchKDE-SystemRestore from GitHub"
info "Target: $DEST"

if command -v git >/dev/null 2>&1; then
  if [ -d "$DEST/.git" ]; then
    info "Updating existing install"
    git -C "$DEST" pull --ff-only
    ok "Updated"
  else
    rm -rf "$DEST"
    git clone "$GIT_URL" "$DEST"
    ok "Downloaded"
  fi
else
  TMP="$(mktemp -d)"
  trap 'rm -rf "$TMP"' EXIT
  curl -fsSL "$ARCHIVE" | tar xz -C "$TMP"
  rm -rf "$DEST"
  mv "$TMP/ArchKDE-SystemRestore-main" "$DEST"
  ok "Downloaded"
fi

echo
# Prefer a system-wide install so `archkde-restore` is on PATH immediately.
if ! "$DEST/install.sh" --global "$@"; then
  printf '\n'
  echo "Global install failed — falling back to ~/.local/bin."
  exec "$DEST/install.sh" "$@"
fi
