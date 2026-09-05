#!/usr/bin/env bash
# Bootstrap this dotfiles repo onto an Omarchy machine.
#   ./install.sh              # stow everything + install packages
#   ./install.sh --no-packages
#   ./install.sh --dry-run
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOST="$(hostname)"
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
DO_PACKAGES=1
DRY=""

for a in "$@"; do
  case "$a" in
    --no-packages) DO_PACKAGES=0 ;;
    --dry-run)     DRY="--simulate --verbose" ;;
    *) echo "unknown flag: $a" >&2; exit 2 ;;
  esac
done

if [ "$(id -u)" = 0 ]; then
  cat >&2 <<'EOF'
Do not run this with sudo.

Under sudo $HOME becomes /root, so stow would link this repo into root's
home directory instead of yours, and every file it created would be owned
by root. Run it as yourself:

    ./install.sh

It will ask for your password only if it needs to install a package.
EOF
  exit 1
fi

command -v omarchy >/dev/null || { echo "This is not an Omarchy system." >&2; exit 1; }
command -v stow    >/dev/null || omarchy pkg add stow

# Portable packages, applied on every host.
PKGS=(bash hypr omarchy nvim opencode git mise apps)

# Host-specific package (monitors.lua etc). Falls back to nothing.
if [ -d "$REPO/hosts/$HOST" ]; then
  echo "==> host profile: hosts/$HOST"
else
  cat >&2 <<EOF
==> No host profile for '$HOST'.

    Display config will NOT be applied. Create one with:

      mkdir -p "$REPO/hosts/$HOST/.config/hypr"
      cp /usr/share/omarchy/config/hypr/monitors.lua \\
         "$REPO/hosts/$HOST/.config/hypr/monitors.lua"

    then edit it for this machine's panel and re-run.
EOF
fi

## 0. Rollback safety ----------------------------------------------------
# Step 1 moves live config out of the way BEFORE stow runs. If stow then fails
# -- or the run is interrupted -- those files would be stranded in the backup
# and simply absent from $HOME, leaving the machine without a shell rc, a git
# identity, or a bar config. Anything moved is put back on any non-zero exit.
ARMED=0
rollback() {
  rc=$?
  trap - EXIT INT TERM
  [ "$ARMED" = 1 ] || exit "$rc"
  [ "$rc" = 0 ] && exit 0
  [ -d "$BACKUP" ] || exit "$rc"
  echo
  echo "!! failed (exit $rc) -- restoring everything moved to $BACKUP"
  local n=0
  while IFS= read -r rel; do
    if [ ! -e "$HOME/$rel" ] && [ ! -L "$HOME/$rel" ]; then
      mkdir -p "$HOME/$(dirname "$rel")"
      mv "$BACKUP/$rel" "$HOME/$rel" && n=$((n+1))
    fi
  done < <(cd "$BACKUP" && find . -type f -printf '%P\n')
  find "$BACKUP" -type d -empty -delete 2>/dev/null || true
  echo "!! restored $n file(s). Your machine is back as it was."
  exit "$rc"
}
trap rollback EXIT INT TERM

## 1. Clear conflicts -----------------------------------------------------
# stow refuses to overwrite a real file. Move anything in the way into a
# timestamped backup, but leave correct symlinks alone so re-runs are cheap.
echo "==> checking for conflicts"
ARMED=1
for pkg in "${PKGS[@]}" ${HOST:+hosts/$HOST}; do
  [ -d "$REPO/$pkg" ] || continue
  while IFS= read -r rel; do
    target="$HOME/$rel"
    src="$REPO/$pkg/$rel"
    [ -e "$target" ] || [ -L "$target" ] || continue
    [ "$(readlink -f "$target" 2>/dev/null)" = "$(readlink -f "$src")" ] && continue
    if [ -n "$DRY" ]; then echo "    would back up: $rel"; continue; fi
    mkdir -p "$BACKUP/$(dirname "$rel")"
    mv "$target" "$BACKUP/$rel"
    echo "    backed up: $rel"
  done < <(cd "$REPO/$pkg" && find . -type f -printf '%P\n')
done

## 2. Stow ----------------------------------------------------------------
echo "==> stowing"
# shellcheck disable=SC2086
# --no-folding is required, not cosmetic. Without it stow replaces a
# directory that does not yet exist with a single symlink to one package
# ("folding"). Both `hypr` and `hosts/<hostname>` place files in
# .config/hypr, so on a machine where that directory is absent the first
# package folds it and the second cannot then add monitors.lua to it:
#   existing target is not owned by stow: .config/hypr
# Real directories keep both packages able to contribute files.
stow $DRY --no-folding -d "$REPO" -t "$HOME" -R "${PKGS[@]}"
if [ -d "$REPO/hosts/$HOST" ]; then
  # shellcheck disable=SC2086
  stow $DRY --no-folding -d "$REPO/hosts" -t "$HOME" -R "$HOST"
fi

ARMED=0   # stow succeeded; the backup is now just a backup

[ -n "$DRY" ] && { echo "dry run complete"; exit 0; }

## 3. Packages ------------------------------------------------------------
if [ "$DO_PACKAGES" = 1 ]; then
  echo "==> packages"
  strip() { grep -vE '^[[:space:]]*(#|$)' "$1" | awk '{print $1}'; }

  # Portable set, plus this host's hardware-coupled set. A package tied to one
  # machine's CPU or GPU never appears in repo.txt, so it can never leak onto
  # the wrong box -- amd-ucode and intel-ucode are not interchangeable.
  HOST_PKGS="$REPO/packages/hosts/$HOST.txt"
  want=$(strip "$REPO/packages/repo.txt")
  if [ -f "$HOST_PKGS" ]; then
    echo "    host package set: packages/hosts/$HOST.txt"
    want="$want"$'\n'"$(strip "$HOST_PKGS")"
  else
    echo "    WARNING: no packages/hosts/$HOST.txt -- installing portable packages only."
    echo "             This host will get no microcode or GPU driver package."
  fi

  missing_repo=$(comm -23 <(printf '%s\n' "$want" | sort -u) <(pacman -Qq | sort) | tr '\n' ' ')
  missing_aur=$(comm -23 <(sort -u "$REPO/packages/aur.txt") <(pacman -Qq | sort) | tr '\n' ' ')

  if [ -n "${missing_repo// }" ]; then
    echo "    installing: $missing_repo"
    omarchy pkg add $missing_repo
  else echo "    repo packages: nothing missing"; fi

  if [ -n "${missing_aur// }" ]; then
    echo "    installing (AUR): $missing_aur"
    omarchy pkg aur add $missing_aur
  else echo "    AUR packages: nothing missing"; fi

fi

## 4. Theme + font --------------------------------------------------------
echo "==> theme and font"
omarchy theme set ayu-darker
omarchy font set "JetBrainsMono Nerd Font"

## 5. Reload --------------------------------------------------------------
omarchy restart shell 2>/dev/null || true
hyprctl reload      2>/dev/null || true
hyprctl configerrors 2>/dev/null || true

echo
echo "Done. Replaced files backed up to: $BACKUP"
echo "Login sync hook installed: ~/.config/omarchy/hooks/post-boot.d/sync-dotfiles.hook"
echo "Not handled here: ~/.ssh, ~/.gnupg, browser profiles, app logins."
