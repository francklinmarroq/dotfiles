# dotfiles

Omarchy 4 configuration, managed with [GNU Stow](https://www.gnu.org/software/stow/).

Replaces the previous vanilla-Arch setup (waybar / wofi / hypridle / hyprlock /
hyprpaper / kitty). Omarchy supplies all of that itself — bar, notifications,
idle, lock and launcher all live in the Omarchy shell — so those packages are
gone. They remain in git history if you ever need them.

## What Stow actually does

Each top-level directory is a **package**. Inside it, the layout mirrors your
home directory. Stow symlinks the leaves into `~`:

    dotfiles/hypr/.config/hypr/input.lua
             └┬─┘ └──────┬──────────────┘
           package   path relative to ~

    $ stow hypr        →  ~/.config/hypr/input.lua -> ~/dotfiles/hypr/.config/hypr/input.lua

Because `~/.config/hypr/` already exists, Stow *folds into* it and links the
single file, rather than replacing the whole directory. That is exactly what we
want: Omarchy keeps ownership of the files it ships, and this repo overrides
only the ones you actually changed.

## Layout

| Package | Links into | Contents |
|---|---|---|
| `bash` | `~` | `.bashrc`, `.bash_profile`, `.profile`, `.XCompose` |
| `hypr` | `~/.config/hypr` | `input.lua` — caps→capslock, `altgr-intl` variant |
| `omarchy` | `~/.config/omarchy` | `shell.json`, custom `ayu-dark`/`ayu-darker` themes, `post-update.d` hooks |
| `nvim` | `~/.config/nvim` | LazyVim config |
| `opencode` | `~/.config/opencode` | config + skills |
| `git` | `~/.config/git` | aliases, rerere, histogram diffs |
| `mise` | `~/.config/mise` | tool versions |
| `apps` | `~/.local/share` | the 2 non-stock desktop entries + their icons |
| `hosts/<hostname>` | `~` | **machine-specific** — `monitors.lua` |

Everything else on this machine is stock Omarchy and is deliberately not
tracked. Tracking upstream defaults only creates merge conflicts on
`omarchy update`.

## Install on a new Omarchy machine

    git clone git@github.com:francklinmarroq/dotfiles.git ~/dotfiles
    cd ~/dotfiles
    ./install.sh --dry-run    # show what would be linked and backed up
    ./install.sh

`install.sh` will:

1. install `stow` if missing;
2. move any conflicting real file to `~/.dotfiles-backup/<timestamp>/`;
3. stow the portable packages, plus `hosts/$(hostname)` if it exists;
4. install missing packages from `packages/repo.txt` and `packages/aur.txt`,
   skipping everything named in `packages/hardware.txt`;
5. apply the `ayu-darker` theme and JetBrainsMono Nerd Font;
6. reload the shell and Hyprland, then run `hyprctl configerrors`.

### Different hardware

`monitors.lua` is per-machine — it carries this laptop's `1.25` scale. It lives
in `hosts/franklaptop/`, not in `hypr/`, so a new box never inherits the wrong
geometry. To add one:

    ./probe-hardware.sh                       # run on the NEW machine
    mkdir -p hosts/$(hostname)/.config/hypr
    cp /usr/share/omarchy/config/hypr/monitors.lua hosts/$(hostname)/.config/hypr/
    $EDITOR hosts/$(hostname)/.config/hypr/monitors.lua
    ./install.sh

Also review `packages/hardware.txt` before installing: it holds `intel-ucode`
(wrong on AMD) and `fprintd`/`libfprint` (pointless without a reader).

## Day-to-day

    stow -R <package>     # re-link after adding files to a package
    stow -D <package>     # unlink
    stow -n -v <package>  # dry run

Since your configs are symlinks, editing `~/.config/hypr/input.lua` edits the
repo. Commit from `~/dotfiles` as normal.

### The one trap: commands that replace files

`omarchy bar ...` and `omarchy toggle ...` rewrite `shell.json` **atomically** —
they write a temp file and `mv` it over the target. That `mv` replaces the
symlink with a regular file, so your edit silently stops reaching the repo.

Check and repair:

    ./bin/dot-resync          # report anything that detached
    ./bin/dot-resync --fix    # copy it back into the repo and re-stow

Worth running before you commit, and any time you have used an `omarchy bar`
or `omarchy toggle` command.

## Not in this repo

`~/.ssh`, `~/.gnupg`, browser profiles and application logins. Move those by
hand, over a channel you trust.
