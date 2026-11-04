#!/bin/sh

set -eu

herdr="${HERDR_BIN_PATH:-herdr}"

if [ "${1:-}" = "--open" ]; then
  exec "$herdr" plugin pane open --plugin herdr-new-space --entrypoint picker --focus >/dev/null
fi

# The popup closes as soon as this exits, so errors go to a toast.
notify() {
  "$herdr" notification show "new space" --body "$1" --sound none >/dev/null 2>&1 || true
}

command -v fzf >/dev/null 2>&1 || {
  notify "fzf not found"
  exit 1
}

expand_home() {
  case "$1" in
    \~ | \~/*) printf '%s' "$HOME${1#\~}" ;;
    *) printf '%s' "$1" ;;
  esac
}

roots() {
  roots_file="${HERDR_PLUGIN_CONFIG_DIR:-}/roots"
  if [ -n "${HERDR_PLUGIN_CONFIG_DIR:-}" ] && [ -f "$roots_file" ]; then
    grep -v '^[[:space:]]*\(#\|$\)' "$roots_file" || true
  else
    printf '%s\n' "$HOME/*"
  fi
}

candidates() {
  zoxide query -l 2>/dev/null || true
  roots | while IFS= read -r root; do
    root="$(expand_home "$root")"
    IFS='
'
    # shellcheck disable=SC2086 # glob the root, the newline IFS keeps spaces in paths
    for dir in $root; do
      if [ -d "$dir" ]; then
        printf '%s\n' "${dir%/}"
      fi
    done
  done
}

choice="$(
  candidates |
    awk '!seen[$0]++' |
    sed "s|^$HOME/|~/|; s|^$HOME\$|~|" |
    fzf --height=100% --prompt 'new space> ' --scheme=path --tiebreak=index
)" || exit 0

dir="$(expand_home "$choice")"

"$herdr" workspace create --cwd "$dir" --focus >/dev/null || notify "could not open $dir"
