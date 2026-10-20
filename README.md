# ArchKDE-SystemRestore

A one-command backup & restore tool for my **Arch / KDE Plasma** setup. It keeps my
configs in sync and makes my fastfetch **"OS Age"** survive a full reinstall.

## What it manages

| Item | Source | Restored to |
|------|--------|-------------|
| fastfetch | `configs/fastfetch-config.jsonc` | `~/.config/fastfetch/config.jsonc` |
| Ghostty | `configs/ghostty-config` | `~/.config/ghostty/config` |
| fish | `configs/fish-config.fish` | `~/.config/fish/config.fish` |
| oh-my-posh | `configs/oh-my-posh/*.omp.json` | `~/.config/oh-my-posh/` |
| OS age | `os-install-date` | `~/.local/state/ArchKDE-SystemRestore/os-install-date` |

## Install

```bash
git clone https://github.com/nizar2004/ArchKDE-SystemRestore.git
cd ArchKDE-SystemRestore
./install.sh
```

`install.sh` does two things:

1. Installs the **`archkde-restore`** command onto your `PATH`
   (`~/.local/bin` by default, or `/usr/local/bin` with `--global`)
2. Runs an initial **restore**

After that, just use the command directly.

## Usage

```bash
archkde-restore backup            # back up current state (OS age + anything else)
archkde-restore backup --label "before tweak"
archkde-restore restore           # restore all configs + OS age
archkde-restore restore --from ~/.local/state/ArchKDE-SystemRestore/backups/20261021-010444
archkde-restore status            # show OS age, backups, and config status
```

## How the OS age survives a reinstall

The install date is stored as a unix timestamp in
`~/.local/state/ArchKDE-SystemRestore/os-install-date`, with a canonical copy in the
repo at `os-install-date`. The fastfetch config reads the age from that file (falling
back to the root filesystem birth time if missing).

1. **First run** — records the current install date into the state file *and* the repo.
2. **Reinstall + fresh clone** — the repo's committed `os-install-date` is copied back,
   so fastfetch keeps showing your *original* install age.

## Adding more backups in the future

Backups are extensible. Drop an executable script into `lib/backup/` and it runs
automatically on every `archkde-restore backup`:

```
lib/backup/
└── 10-os-age          # already backs up the OS install date
```

Each script receives the backup destination as `$1` and can use these env vars:

| Variable | Meaning |
|----------|---------|
| `$1` | backup destination directory |
| `$AKSR_BACKUP_DIR` | same as `$1` |
| `$AKSR_DATE_STATE` | current install-date state file |
| `$AKSR_REPO_DIR` | repo root |
| `$AKSR_STATE_DIR` | `~/.local/state/ArchKDE-SystemRestore` |

Prefix the filename with a number to control ordering (`10-`, `20-`, …). Print a short
description on success — the caller shows it in the backup summary.

Backups are stored in `~/.local/state/ArchKDE-SystemRestore/backups/<timestamp>/` with a
`manifest.txt`.

## Requirements

- Arch Linux / CachyOS (pacman); Debian/Ubuntu (`apt`) also handled for deps.
- `sudo` or `pkexec` for package installation / global command install.
