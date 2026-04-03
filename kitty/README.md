# Kitty Configuration

## Keybindings

`kitty_mod` is `Ctrl+Shift` by default.

| Key | Action |
|-----|--------|
| `Ctrl+Shift+H` | Open full scrollback in Neovim (kitty-scrollback.nvim) |
| `Ctrl+Shift+G` | Open last command's output in Neovim |
| `Ctrl+Shift+Right-click` | Open clicked command's output in Neovim |
| `Ctrl+Shift+E` | Select and open URLs from visible text (hints) |
| `Ctrl+Shift+P > F` | Select file paths from visible text |
| `Ctrl+Shift+P > N` | Select file:line references, open in `$EDITOR` |
| `Ctrl+Shift+P > Y` | Select hyperlinks |
| `Opt+Cmd+,` | Debug config (dump resolved settings) |
| `Ctrl+Cmd+,` | Reload config without restarting |

## Kittens (built-in tools)

### SSH (`kitten ssh`)

Drop-in `ssh` replacement. Aliased as `ssh` in zsh.

- Auto-copies terminfo (fixes `xterm-kitty` on remote hosts)
- Deploys shell integration on the remote
- Reuses connections -- subsequent SSH to the same host is near-instant
- Supports per-host config in `~/.config/kitty/ssh.conf`

### Hyperlinked Grep (`kitten hyperlinked-grep`)

Wraps ripgrep so results are clickable -- click to open the file at the match
line in Neovim. Aliased as `hg` in zsh.

### Hints (`kitten hints`)

Scans visible terminal text for URLs, file paths, file:line refs, git SHAs,
IPs, etc. Lets you select and act on them (open, copy, paste, run program).
Use `--type=regex --regex='...'` for custom patterns.

### Other useful kittens

```bash
kitten icat image.png              # display image inline in terminal
kitten diff file1 file2            # side-by-side diff with syntax highlighting
kitten clipboard < file.txt        # copy text to system clipboard (works over SSH)
kitten clipboard /path/to/img.png  # copy image to clipboard (OSC 52 can't do this)
kitten clipboard --get-clipboard   # paste clipboard to stdout
kitten transfer file.txt           # transfer files over existing SSH session
kitten themes                      # browse and live-preview 300+ color themes
kitten fonts                       # preview and switch fonts interactively
kitten broadcast                   # type in one window, input goes to all windows
kitten unicode_input               # insert Unicode characters by name/code (Ctrl+Shift+U)
```

## Clipboard: OSC 52 vs `kitten clipboard`

OSC 52 handles plain text clipboard over SSH natively -- no setup needed.
`kitten clipboard` adds file and image support (binary data over SSH).
For most workflows, OSC 52 is sufficient.

## Remote control

`allow_remote_control socket-only` is enabled for kitty-scrollback.nvim.
This allows `kitten @` commands only via the Unix socket (`/tmp/kitty`),
not from programs writing escape sequences to the terminal.

```bash
kitten @ ls                        # list kitty windows
kitten @ set-colors --all ...      # change colors on the fly
kitten @ send-text --all '...'     # send text to all windows
```

## Theme

Current theme: **Gruvbox Dark** (`current-theme.conf`).
Switch with `kitten themes` -- it writes the include file automatically.

## Notes

- `macos_option_as_alt yes` makes Option key send Alt/Meta instead of Unicode
  special characters. Required for terminal keybindings like Alt+B/F.
- `listen_on` and `allow_remote_control` require a full Kitty restart (not just
  config reload) to take effect.
- The Nix-installed Kitty binary is re-signed by a home-manager activation
  script to fix macOS notifications (see `home.nix:fixKittyNotifications`).
- Generate the default config reference:
  `kitty +runpy 'from kitty.config import *; print(commented_out_default_config())'`
