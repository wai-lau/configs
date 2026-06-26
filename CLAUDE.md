# CLAUDE.md

> **Scope:** Applies ONLY to the dotfiles repo rooted at `$HOME`
> (`/home/wai`) — editing `.vimrc`, `.zshrc`, `.tmux.conf`, Vim
> submodules, etc. Claude Code loads this file for any cwd under
> `/home/wai` (parent-dir traversal), but it does NOT apply to
> subdirectory projects like `~/src/*`. If cwd is a distinct
> project (its own git repo / package), IGNORE this file and use
> that project's own instructions.

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

Personal dotfiles for a WSL2/Linux + tmux + Vim environment. Tracked files are whitelisted in `.gitignore` (everything ignored by default, explicit allowlist). Vim plugins live in `.vim/bundle/` as git submodules.

## Tracked Files

| File/Dir | Purpose |
|----------|---------|
| `README.md` | Public-facing repo overview (layout, install, highlights, host gating) |
| `.vimrc` | Vim config — Vundle plugins, keymaps, ALE/syntastic, per-filetype color schemes |
| `.zshrc` | Shell — PATH, Go env, rbenv, FZF, compinit |
| `.alias.zsh` | Aliases and shell functions (`@`, `@pr`, `rubylint`, `swo`) |
| `.local.zsh` | Tracked machine-local env vars (non-secret; empty by default). Secrets go in gitignored `~/.secrets`, not here. |
| `.tmux.conf` | Tmux — Alt+hjkl pane nav shared with Vim, window bindings, colors |
| `.gitconfig` | Git aliases (`g ff`, `g f`, `g fp`, `g l`) |
| `.vim/bundle/*` | Vim plugins as git submodules (managed by Vundle) |

## Host Gating (shared master across hosts)

One `master` branch is shared by two hosts — no branch-per-host:

- **WSL-local** workstation (`/mnt/c` present, `$SSH_CONNECTION` empty)
- **Droplet** `root@wai-lau.net` (over ssh/mosh, `$SSH_CONNECTION` set)

Config is mostly shared; diverge ONLY where intentional, and gate
every host-specific thing so it never runs on the wrong host:

| Mechanism | Use for |
|-----------|---------|
| `[[ -d /mnt/c ]]` | WSL/Windows-interop only (`clip.exe`, Windows `$BROWSER`, Obsidian) |
| `[ -z "$SSH_CONNECTION" ]` | outer-host-only tmux (nested `M-q` toggle) |
| `[[ -d <path> ]]` presence | optional tooling (linuxbrew, project dirs) |
| `command -v <tool>` | tool-dependent lines (`pass`/`GH_TOKEN`) |
| `~/.secrets` (gitignored) | raw secrets / credentials (sourced by `.zshrc`) |
| `~`-relative paths | shared paths that resolve per-host (`~/bin/...`, gitconfig keys) |

Never hardcode `/home/wai` in tracked config — droplet home is `/root`.
Project tooling (e.g. `voice`/hosaka) does NOT belong here; it lives in
its own repo, symlinked into `~/bin` for global use.

## Reference Docs

Operational deep-dives for this environment live in `docs/` (committed):

- [`docs/clipboard-osc52.md`](docs/clipboard-osc52.md) — drag-copy /
  OSC52 through WT + nested tmux + SSH; why `~/bin/tmux-osc52` exists.
- [`docs/shift-enter-csiu.md`](docs/shift-enter-csiu.md) — Shift+Enter
  via CSI u through WT + tmux + SSH.

## Adding a New Dotfile to Tracking

`.gitignore` whitelists everything. To track a new file, add an explicit `!` rule:

```
!.newfile
```

For directories, add both the dir and a recursive glob:

```
!.newdir
!.newdir/*
!.newdir/**/*
```

## Vim Plugin Management

Plugins are Vundle-managed submodules. To add a plugin:

1. Add `Plugin 'author/repo'` to `.vimrc` (inside `vundle#begin()`/`vundle#end()`)
2. `git submodule add git@github.com:author/repo.git .vim/bundle/repo`
3. In Vim: `:PluginInstall`

To remove: delete the `Plugin` line, `git submodule deinit` + `git rm`, then `:PluginClean`.

## Key Vim Conventions

- `jk` → Esc in insert mode
- `;` / `:` swapped (`;` opens command mode)
- `}` / `"` / `?` → go-to-definition (in tab / in place / in vsplit) — language-aware via ALE or vim-go
- `Ctrl+@` → NERDTree toggle; `Ctrl+n` → NERDTree find
- `Ctrl+g` (visual) → search selection with `Ggrep` across same filetype
- `Alt+hjkl` → navigate Vim/tmux panes seamlessly
- `#····` tag markers used in Ruby files for jump-to-task workflow (`:GGGG` searches them)
- `:GG <term>` → grep across same filetype; `:GGG <term>` → grep all files

## Git Aliases (`.gitconfig`)

| Alias | Expands to |
|-------|-----------|
| `g ff` | fetch + rebase origin default branch + force-push current branch |
| `g f` | `add -A && commit --amend --no-edit` |
| `g fp` | `push --force-with-lease` current branch |
| `g l` | `log --oneline --graph` |
| `g bb` | `checkout -b` |

## Commit Messages

Always invoke `/caveman:caveman-commit` skill before writing commit messages.

## Pushing

Always `git push` after committing in this repo — never leave commits
sitting locally. Both hosts (WSL-local + droplet) track `master` and
pull from origin, so unpushed commits strand the other host.

## Shell Functions

- `@` — `cd ~/src` or `cd ~/src/<fuzzy-match>`
- `@pr` — open GitHub PR for current branch in browser
- `rubylint` — run `rubocop -a` on git-changed Ruby files only
- `swo` — recover vim swap files and open originals
