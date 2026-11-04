# herdr-new-space

A [herdr](https://herdr.dev) plugin that opens a new space in a directory you pick.

`[terminal] new_cwd` applies to panes, tabs and spaces alike, so a fixed default directory breaks `follow` for splits. This picks the directory per space instead: a popup lists your [zoxide](https://github.com/ajeetdsouza/zoxide) directories and project roots, fuzzy-find one with [fzf](https://github.com/junegunn/fzf), and the space opens there. Esc cancels.

## Install

```bash
herdr plugin install reobin/herdr-new-space
```

Requires herdr 0.9.0 or newer and `fzf`. `zoxide` is optional: without it the list is just your roots.

## Use

Bind the action to a key in `~/.config/herdr/config.toml`, then `herdr server reload-config`:

```toml
[[keys.command]]
key = "alt+n"
type = "plugin_action"
command = "herdr-new-space.new"
description = "new space in a picked directory"
```

It also shows up in the command palette as **New space in a picked directory**.

## Roots

The roots file lists the directories to offer besides zoxide's, one per line. A plain path lists itself, a glob lists what it matches, `~` is your home and `#` starts a comment. Without the file, the roots are `~/*`.

```bash
cat > "$(herdr plugin config-dir herdr-new-space)/roots" <<'EOF'
~/code/*
~/dotfiles
EOF
```

## License

MIT
