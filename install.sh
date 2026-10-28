#!/usr/bin/env bash
#
# ArchKDE-SystemRestore — first-time bootstrap
#
# 1. Installs every package needed (fastfetch, ghostty, fish, oh-my-posh, git, curl)
# 2. Sets fish as the default shell
# 3. Installs the `archkde-restore` command onto your PATH
# 4. Runs an initial restore of your configs + OS age
#
# After this, just use the command directly:
#   archkde-restore backup
#   archkde-restore restore
#   archkde-restore status
#
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLI="$REPO_DIR/archkde-restore"

[ -x "$CLI" ] || { printf 'error: missing %s\n' "$CLI" >&2; exit 1; }

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
die() { printf '\033[1;31m ✗ \033[0m %s\n' "$*" >&2; exit 1; }

# --- ask for the sudo password ONCE, up front ---
# Everything privileged later (pacman, chsh, /usr/local/bin) reuses the
# cached credentials instead of failing mid-run.
if [ "$(id -u)" -ne 0 ]; then
  if command -v sudo >/dev/null 2>&1; then
    info "This will install packages and system files — asking for your password once"
    sudo -v || die "sudo access is required. Run this script again and enter your password."
  elif command -v pkexec >/dev/null 2>&1; then
    info "sudo not found — privileged steps will use pkexec (polkit) prompts"
  else
    die "Neither sudo nor pkexec found. Run this script as root instead."
  fi
else
  info "Running as root — skipping the password prompt"
fi

info "Installing all required packages"
"$CLI" deps

echo
info "Installing the archkde-restore command"
"$CLI" install "$@"

echo
info "Restoring your setup"
"$CLI" restore

echo
info "Done! In the future use: archkde-restore {backup|restore|status}"
if [ "$(getent passwd "$(id -un)" | cut -d: -f7)" != "/usr/bin/fish" ] && [ -x /usr/bin/fish ]; then
  printf '\033[1;33m !  \033[0m %s\n' "Log out and back in (or reboot) to make fish your login shell."
  printf '%s\n' "   New Ghostty windows already run fish, so fastfetch + the prompt show right away."
fi
