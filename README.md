# ArchKDE-SystemRestore

A one-command backup & restore tool for my **Arch / KDE Plasma** setup. It keeps my
configs in sync and makes my fastfetch **"OS Age"** survive a full reinstall.

## What it manages

| Item | Source | Restored to |
|------|--------|-------------|
| fastfetch | `configs/fastfetch-config.jsonc` | `~/.config/fastfetch/config.jsonc` |
| Ghostty | `configs/ghostty-config` | `~/.config/ghostty/config` |
| fish | `configs/fish-config.fish` | `~/.config/fish/config.fish` |
| fish functions | `configs/fish-functions/*.fish` | `~/.config/fish/functions/` |
| oh-my-posh | `configs/oh-my-posh/*.omp.json` | `~/.config/oh-my-posh/` |
| OS age | `os-install-date` | `~/.local/state/ArchKDE-SystemRestore/os-install-date` |

## Install

Run this single command — **no git clone needed**:

```bash
curl -fsSL https://raw.githubusercontent.com/nizar2004/ArchKDE-SystemRestore/main/remote-install.sh | bash
```

Designed for a **fresh Arch reinstall**. It:

1. Installs every required package — `fastfetch`, `ghostty`, `fish`, `git`, `curl`,
   `fzf`, `ttf-meslo-nerd` (the font the Ghostty config uses; `oh-my-posh` is pulled from
   its official release binary, since it's not in the repos) — and builds **yay** from
   the AUR, so the `yaysrch` fuzzy package-searcher works out of the box
2. If the copy was downloaded as a tarball (no `git` on the live ISO yet), converts
   it into a real git clone once `git` is installed — so `backup` can push to GitHub
3. Asks for the **sudo password once, up front**, then does all privileged work
   (packages, oh-my-posh, default shell) in a single root step
4. Sets **fish** as the default shell — and the Ghostty config starts fish directly,
   so fastfetch + oh-my-posh appear in new windows immediately (the login-shell
   change itself needs a log out/in)
5. Downloads the project to `~/.local/share/ArchKDE-SystemRestore` (persistent, so the
   `archkde-restore` command keeps working), installs the command onto your `PATH`
6. Runs an initial restore

Prefer to clone manually? That works too:

```bash
git clone https://github.com/nizar2004/ArchKDE-SystemRestore.git
cd ArchKDE-SystemRestore
./install.sh
```

After that, just use the command directly. To update later: `archkde-restore update`.

## Usage

Run it with **no arguments** and a styled interactive menu opens — the two
commands that matter:

```text
  ╭────────────────────────────────────────────╮
  │ ARCHKDE-SYSTEMRESTORE - v1.2.0             │
  │ my Arch/KDE setup, in one command          │
  ╰────────────────────────────────────────────╯

   What do you want to do?

     1)  Backup    save the current setup & push it to GitHub

     2)  Restore   put everything back on this machine

     q)  Quit

   >> press a key:
```

Both also work directly from the shell:

```bash
archkde-restore backup              # back up + push to GitHub
archkde-restore backup --label "before tweak"
archkde-restore backup --no-push    # back up locally only
archkde-restore restore             # restore all configs + OS age
archkde-restore restore --from latest
archkde-restore restore --from ~/.local/state/ArchKDE-SystemRestore/backups/20261021-010444
```

Advanced commands (kept for the installer/maintenance, not in the menu):

```bash
archkde-restore update              # pull the latest version of the installed copy
archkde-restore status              # show OS age, backups, and config status
archkde-restore install             # install the command onto your PATH
archkde-restore deps                # install required packages (fresh Arch)
```

## Backups go to GitHub

Every `backup` is stored in the repo at `backups/<timestamp>/`, committed, and pushed.
So after a fresh reinstall, a fresh clone already contains every backup and you can
restore with `archkde-restore restore --from latest`.

Backups are created in the copy of the repo you run the command from. Use
`archkde-restore update` to pull the installed copy up to date.

## How the OS age works

The install date is stored as a unix timestamp in
`~/.local/state/ArchKDE-SystemRestore/os-install-date`, with a copy in the repo at
`os-install-date`. The fastfetch config reads the age from that file (falling back to
the root filesystem birth time if missing).

- **First run** — records the current install date into the state file *and* the repo.
- **`backup`** — refreshes the stored age to the **current** OS age at that moment
  (reads the running system's install date and overwrites the state + repo copies), so
  fastfetch immediately shows the age as it is right now.
- **`restore`** — copies the repo's `os-install-date` back into the state file.

In short: `backup` always makes the OS age reflect **now**.

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

- Arch Linux / CachyOS
- `sudo` or `pkexec` for package installation / global command install

The installer handles the rest — including `oh-my-posh`, which it pulls from the
official GitHub release since it's not in the official repos.
