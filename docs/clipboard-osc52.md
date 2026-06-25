# Clipboard pipeline (WT + WSL2 + tmux + SSH)

How drag-copy / OSC52 reaches the Windows clipboard through Windows
Terminal, nested tmux, and SSH. tmux's `set-clipboard` relay is
unreliable in this nested setup; we bypass it by writing OSC52
straight to the client tty via `~/bin/tmux-osc52`.

## What works in WT 1.24

- WT accepts OSC52 with **both** BEL (`\a`) and ST (`\e\\`) terminators.
- ConPTY/WSL bridge passes OSC52 through transparently (verified by
  writing directly to `/dev/pts/0`).
- Default OSC52 selection target `c` (clipboard) works.

## What's broken

- tmux `set-clipboard on` intercepts inner-app OSC52 into a buffer, but
  the re-emit to the outer terminal via the `Ms` capability doesn't
  reach WT's clipboard when nested. `refresh-client -l`, `set-buffer -w`,
  and inner-app `printf '\e]52;...'` all fail to update WT.
- `terminal-overrides` for `Ms` doesn't take effect on already-attached
  clients — `source-file` doesn't reload terminal capabilities.
- Default tmux `clipboard`/`extkeys` features are scoped to `xterm*`.
  Nested tmux's outer TERM is `screen-256color`, so the glob misses and
  the features don't activate.

## Working approach: write OSC52 to client tty

`~/bin/tmux-osc52` reads the selection on stdin, base64-encodes it,
looks up `tmux display -p '#{client_tty}'`, and writes OSC52 directly.
With `--wrap` it wraps in tmux passthrough (`\ePtmux;\e<doubled-esc>\e\\`)
so an *outer* tmux strips one layer and forwards plain OSC52.

| Layer | Mode | Why |
|-------|------|-----|
| Local tmux pane | plain (no wrap) | only one layer; OSC52 goes straight to WT via pts |
| SSH'd remote tmux pane | `--wrap` | remote tmux strips wrapper, emits plain OSC52 to its client tty (= ssh PTY) → local tmux `allow-passthrough on` forwards verbatim → WT |

Bind:

```
bind-key -T copy-mode-vi MouseDragEnd1Pane \
  send-keys -X copy-pipe '~/bin/tmux-osc52 [--wrap]' \; \
  send-keys -X cancel
```

Helper location (per-host, `~`-relative in config):
- Local: `/home/wai/bin/tmux-osc52`
- Droplet (root@wai-lau.net): `/root/bin/tmux-osc52`

> NOTE: `~/bin/tmux-osc52` is NOT tracked in this repo. It must exist on
> each host independently (copy/scp it). The tmux binding pipes to it.

## Required tmux config (both hosts)

```
set -g allow-passthrough on
set -g set-clipboard on
set -as terminal-features 'screen*:extkeys:clipboard'  # nested TERM
set -as terminal-features 'xterm*:extkeys'             # outer TERM (WT)
```

## Known quirks

- `copy-pipe-and-cancel` and explicit `copy-pipe \; send-keys -X cancel`
  both leave the visual selection highlighted here. Copy still happens.
- `.tmux-off.conf` does `unbind -a -T root`, wiping default mouse/wheel
  root bindings. tmux only loads defaults at startup, so re-sourcing
  `.tmux.conf` does NOT restore them. Fix: re-declare the defaults
  explicitly in `.tmux.conf` (MouseDown1/2/3Pane, MouseDrag1Pane,
  MouseDragEnd1Pane, WheelUp/DownPane).
- Drag-to-copy in WT directly (outside tmux) needs Shift held, since
  tmux `mouse on` captures all mouse events. With this config, drag in
  tmux copies via OSC52, so Shift+drag is rarely needed.

## Diagnostic recipes

| Test | Command | Where |
|------|---------|-------|
| WT accepts OSC52 | `printf '\e]52;c;%s\a' "$(echo -n X|base64)"` | fresh WT tab outside tmux |
| pts → WT chain | same printf redirected to `/dev/pts/0` | any process |
| tmux relay (usually fails) | `tmux set-buffer X; tmux refresh-client -l` | inside tmux |
| end-to-end | drag-select with binding installed | any tmux pane |
