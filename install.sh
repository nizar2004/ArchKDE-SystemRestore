#!/usr/bin/env bash
#
# ArchKDE-SystemRestore — first-time bootstrap
#
# 1. Installs the `archkde-restore` command onto your PATH
# 2. Runs an initial restore of your configs + OS age
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

info "Installing the archkde-restore command"
"$CLI" install "$@"

echo
info "Restoring your setup"
"$CLI" restore

echo
info "Done! In the future use: archkde-restore {backup|restore|status}"
