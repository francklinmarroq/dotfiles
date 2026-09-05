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

## 1. Clear conflicts -----------------------------------------------------
# stow refuses to overwrite a real file. Move anything in the way into a
# timestamped backup, but leave correct symlinks alone so re-runs are cheap.
echo "==> checking for conflicts"
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
stow $DRY -d "$REPO" -t "$HOME" -R "${PKGS[@]}"
if [ -d "$REPO/hosts/$HOST" ]; then
  # shellcheck disable=SC2086
  stow $DRY -d "$REPO/hosts" -t "$HOME" -R "$HOST"
fi

[ -n "$DRY" ] && { echo "dry run complete"; exit 0; }

## 3. Packages ------------------------------------------------------------
if [ "$DO_PACKAGES" = 1 ]; then
  echo "==> packages"
  skip=$(grep -vE '^\s*(#|$)' "$REPO/packages/hardware.txt" | awk '{print $1}' | sort -u)
  want_repo=$(comm -23 <(sort -u "$REPO/packages/repo.txt") <(printf '%s\n' "$skip"))
  missing_repo=$(comm -23 <(printf '%s\n' "$want_repo") <(pacman -Qq | sort) | tr '\n' ' ')
  missing_aur=$(comm -23 <(sort -u "$REPO/packages/aur.txt") <(pacman -Qq | sort) | tr '\n' ' ')

  if [ -n "${missing_repo// }" ]; then
    echo "    installing: $missing_repo"
    omarchy pkg add $missing_repo
  else echo "    repo packages: nothing missing"; fi

  if [ -n "${missing_aur// }" ]; then
    echo "    installing (AUR): $missing_aur"
    omarchy pkg aur add $missing_aur
  else echo "    AUR packages: nothing missing"; fi

  echo "    NOTE: skipped as hardware-specific: $(echo $skip)"
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
echo "Not handled here: ~/.ssh, ~/.gnupg, browser profiles, app logins."
