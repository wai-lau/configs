# Shift+Enter pipeline (CSI u)

How Shift+Enter delivers a newline (not a submit) to Claude Code through
Windows Terminal, tmux, and SSH using CSI u encoding.

WT sends `[13;2u` (CSI u: keycode 13 + modifier 2) on Shift+Enter.
Claude Code reads this as newline-in-prompt without submitting.

## Windows Terminal `settings.json`

Path:
`/mnt/c/Users/wailu/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json`

```json
{
  "command": { "action": "sendInput", "input": "[13;2u" },
  "id": "User.sendInput.8882FD6D",
  "keys": "shift+enter"
}
```

## tmux `.tmux.conf` (required for tmux + SSH)

```
set -s extended-keys on
set -as terminal-features 'xterm*:extkeys'
```

Without these, tmux normalizes Shift+Enter back to plain Enter. With
them, the CSI u bytes pass through to the inner program. Works
transparently over SSH — the remote tmux needs the same config.

## If Shift+Enter stops working

Check, in order:
1. WT keybind still present (`settings.json` above).
2. tmux has both `extended-keys on` and the `extkeys` terminal-feature.
3. `tmux -V` >= 3.2.
