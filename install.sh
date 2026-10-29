#!/usr/bin/env bash
#
# ArchKDE-SystemRestore — first-time bootstrap
#
# 1. Installs every package needed (fastfetch, ghostty, fish, oh-my-posh, git, curl)
# 2. Sets fish as the default shell
# 3. Installs the `archkde-restore` command onto your PATH
# 4. Runs an initial restore of your configs + OS age
#
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLI="$REPO_DIR/archkde-restore"

[ -x "$CLI" ] || { printf 'error: missing %s\n' "$CLI" >&2; exit 1; }

# --- styling (auto-disabled when output isn't a real terminal) ---
if [ -t 1 ]; then
  C=$'\033[1;34m' G=$'\033[1;32m' Y=$'\033[1;33m' W=$'\033[1;37m' D=$'\033[0;90m' R=$'\033[0m'
else
  C='' G='' Y='' W='' D='' R=''
fi

# Box helpers — content padded to exactly 42 ASCII columns so the right
# border always lines up, in every terminal.
MENU_H="$(printf '\u2500%.0s' {1..44})"
box_top() { printf '  %b\u256d%s\u256e%b\n' "$C" "$MENU_H" "$R"; }
box_row() { printf '  %b\u2502%b %b%-42s%b %b\u2502%b\n' "$C" "$R" "$1" "$2" "$R" "$C" "$R"; }
box_bot() { printf '  %b\u2570%s\u256f%b\n' "$C" "$MENU_H" "$R"; }
step()    { printf '\n  %b%s%b  %b%s%b\n' "$D" "$1" "$R" "$W" "$2" "$R"; }
info()    { printf '%s\n' "${C}==>${R} $*"; }
ok()      { printf '%b\n' "${G} \u2713 ${R}$*"; }
warn()    { printf '%s\n' "${Y} ! ${R} $*"; }

banner() {
  printf '\n'
  box_top
  box_row "$W" "ARCHKDE-SYSTEMRESTORE - INSTALLER"
  box_row "$D" "one command -> your whole setup back"
  box_bot
}

summary() {
  printf '\n'
  box_top
  box_row "$G" "SETUP COMPLETE"
  box_bot
  printf '\n'
  printf '   %bWhat just happened:%b\n' "$W" "$R"
  printf '   %b\u2713%b fastfetch / ghostty / fish / oh-my-posh installed\n' "$G" "$R"
  printf '   %b\u2713%b fish set as your default shell\n' "$G" "$R"
  printf '   %b\u2713%b %barchkde-restore%b command available anywhere\n' "$G" "$R" "$W" "$R"
  printf '   %b\u2713%b configs restored - OS age preserved\n\n' "$G" "$R"
  printf '   %bOpen a new terminal: fastfetch greets you.%b\n\n' "$W" "$R"
  printf '   %bAnytime:%b  %barchkde-restore%b (menu)   %barchkde-restore backup%b (save + push)\n\n' "$D" "$R" "$W" "$R" "$W" "$R"
}

banner

step "1/5" "Access"
if [ "$(id -u)" -eq 0 ]; then
  ok "Running as root - no password needed"
elif sudo -n true 2>/dev/null; then
  ok "sudo credentials already cached"
else
  info "Asking for the sudo password once - everything after this runs without prompting"
  if sudo -v; then
    ok "sudo ready"
    # Keep the cached credentials alive for the whole install (pacman builds can be slow).
    ( while sleep 50; do sudo -n true 2>/dev/null || exit; done ) &
    SUDO_KEEPALIVE_PID=$!
    trap 'kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true' EXIT
  else
    warn "Could not cache sudo credentials here - per-step prompts or polkit will ask instead"
  fi
fi

step "2/5" "Packages"
"$CLI" deps

step "3/5" "Command"
"$CLI" install "$@"

step "4/5" "Configs"
"$CLI" restore

step "5/5" "Done"
summary
