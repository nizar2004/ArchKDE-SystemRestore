# Nizar Restore — Arch / KDE Plasma

A one-command restore script for my personal setup. Running it re-applies:

1. **fastfetch** — my custom `config.jsonc` (Tokyo Night colours, OS age module)
2. **Ghostty** — my custom terminal theme (background `#1c1c1c`, Tokyo Night palette)
3. **OS install date** — persisted so the fastfetch **"OS Age"** module keeps counting from the
   original install day, even after a full reinstall.

## Install

```bash
git clone https://github.com/<your-user>/nizar-restore.git
cd nizar-restore
./install.sh
```

That's it. It installs `fastfetch` + `ghostty` if they're missing, backs up any existing
configs as `*.bak`, and writes your configs in place.

## How the OS Age survives reinstall

`install.sh` stores the install date as a unix timestamp in:

```
~/.local/state/nizar-restore/os-install-date
```

and keeps a copy in the repo root at `os-install-date`. The fastfetch config reads the age
from that file, falling back to the root filesystem birth time if the file is missing.

So the flow is:

1. **First run** — records the current root birth time into the state file *and* the repo.
2. **Reinstall + fresh clone** — the repo's committed `os-install-date` is copied back into
   the state file, so fastfetch keeps showing your *original* install age.

## Uninstall / revert

```bash
rm -f ~/.config/fastfetch/config.jsonc.bak ~/.config/ghostty/config.bak   # remove backups
# restore backups if you want the pre-script state:
cp ~/.config/fastfetch/config.jsonc.bak ~/.config/fastfetch/config.jsonc
cp ~/.config/ghostty/config.bak ~/.config/ghostty/config
```

## Requirements

- Arch Linux / CachyOS (pacman) — Debian/Ubuntu (`apt`) also supported for the deps install.
- `sudo` or `pkexec` for package installation (use `./install.sh --no-deps` to skip it).
