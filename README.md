# dotfiles

Personal dotfiles for a WSL2/Linux environment built around
**tmux + Vim + zsh**. One `master` branch is shared across two hosts
(a WSL-local workstation and a remote droplet); host-specific bits are
gated so nothing runs on the wrong machine.

The repo is rooted at `$HOME`. `.gitignore` ignores everything by
default and whitelists tracked files explicitly, so a stray dotfile is
never committed by accident.

## Layout

| File / dir | Purpose |
|------------|---------|
| `.vimrc` | Vim — Vundle plugins, keymaps, ALE LSP, per-filetype colorschemes |
| `.zshrc` | Shell — prompt, PATH, Go/rbenv, FZF, completion, `claude` wrapper |
| `.alias.zsh` | Aliases + functions (`@`, `@pr`, `swo`, `rubylint`) |
| `.local.zsh` | Tracked machine-local env (non-secret; empty by default) |
| `.tmux.conf` | tmux — Alt+hjkl pane nav, OSC52 clipboard, CSI u keys, TPM |
| `.tmux-off.conf` | Nested-tmux toggle target (outer bindings off via `M-q`) |
| `.gitconfig` | Git aliases and SSH-signing config |
| `.claude/` | Claude Code statusline + instructions |
| `.vim/bundle/*` | Vim plugins as git submodules (21, Vundle-managed) |
| `docs/` | Operational deep-dives (see below) |

## Install

Clone into `$HOME` with submodules:

```sh
git clone --recursive \
  git@github.com:wai-lau/configs.git ~/dotfiles
```

Because tracking is rooted at `$HOME`, either clone the work tree
directly over your home directory or symlink the individual files. Then
in Vim run `:PluginInstall` to populate any new plugins.

Secrets are never committed — `.zshrc` sources a gitignored
`~/.secrets` if present; tokens come from `pass` where available.

## Highlights

### Vim

- Linting/LSP via **ALE** (`pylsp`, `solargraph`, `tsserver`); Go via
  `vim-go`. ALE is the sole linter.
- `jk` -> Esc; `;` / `:` swapped (`;` opens command mode).
- `}` / `"` / `?` -> go-to-definition in tab / in place / in vsplit,
  language-aware.
- `Ctrl-@` -> NERDTree toggle; `Ctrl-n` -> NERDTree find.
- `Alt-hjkl` -> seamless Vim/tmux pane navigation (`N()` function falls
  through to `tmux select-pane`).
- `:GG <term>` grep same filetype; `:GGG` grep all; `:GGGG` jump to
  `#····` task markers.
- Per-filetype colorschemes (zenburn / sift / sialoquent) swap on
  `BufEnter`.

### tmux

- `Alt-hjkl` pane nav forwarded to Vim when Vim is the active pane.
- `Alt-;` / `Alt-'` split; `Alt-1..0` window select; `Alt-z` reorder.
- Drag-to-copy emits OSC52 straight to the client tty (reliable across
  nested tmux + WSL + SSH); see `docs/`.
- `continuum` auto-save/restore; windows/panes 1-indexed.

### zsh

- Minimal prompt: time, ssh marker, 2-dir path, exit-status star.
- `@` -> `cd ~/src` or fuzzy `~/src/<match>`; `@pr` opens the current
  branch's PR (or compare page); `swo` recovers Vim swap files;
  `rubylint` runs `rubocop -a` on changed Ruby files.
- `claude` wrapper injects `~/.claude/private.md` as an appended system
  prompt for interactive sessions only.

### git aliases

| Alias | Does |
|-------|------|
| `g ff` | fetch + rebase origin default + force-push current branch |
| `g f` | `add -A && commit --amend --no-edit` |
| `g fp` | `push --force-with-lease` |
| `g bb` | `checkout -b` |
| `g l` | `log --oneline --graph` |

## Two-host gating

Config is mostly shared; divergence is gated so each line is inert on
the wrong host:

| Mechanism | Used for |
|-----------|----------|
| `[[ -d /mnt/c ]]` | WSL/Windows interop (Windows `$BROWSER`, `wslview`) |
| `[ -z "$SSH_CONNECTION" ]` | outer-host-only tmux (`M-q` nested toggle) |
| `command -v <tool>` | optional tooling (`pass`, `xdg-open`) |
| `~/.secrets` | gitignored credentials, sourced if present |

Paths are `~`-relative, never hardcoded to `/home/wai` (the droplet
home is `/root`).

## Docs

- [`docs/clipboard-osc52.md`](docs/clipboard-osc52.md) — drag-copy /
  OSC52 through Windows Terminal + nested tmux + SSH.
- [`docs/shift-enter-csiu.md`](docs/shift-enter-csiu.md) — Shift+Enter
  via CSI u through the same stack.

## Adding a tracked file

`.gitignore` is an allowlist. Add an explicit rule:

```
!.newfile
```

For a directory, add the dir and recursive globs:

```
!.newdir
!.newdir/*
!.newdir/**/*
```
