# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

Personal dotfiles for a WSL2/Linux + tmux + Vim environment. Tracked files are whitelisted in `.gitignore` (everything ignored by default, explicit allowlist). Vim plugins live in `.vim/bundle/` as git submodules.

## Tracked Files

| File/Dir | Purpose |
|----------|---------|
| `.vimrc` | Vim config — Vundle plugins, keymaps, ALE/syntastic, per-filetype color schemes |
| `.zshrc` | Shell — PATH, Go env, rbenv, FZF, compinit |
| `.alias.zsh` | Aliases and shell functions (`@`, `@pr`, `rubylint`, `swo`) |
| `.local.zsh` | Machine-local env vars (empty/gitignored content) |
| `.tmux.conf` | Tmux — Alt+hjkl pane nav shared with Vim, window bindings, colors |
| `.gitconfig` | Git aliases (`g ff`, `g f`, `g fp`, `g l`) |
| `.vim/bundle/*` | Vim plugins as git submodules (managed by Vundle) |
| `.config/karabiner/` | macOS key remapping |
| `.config/iterm2/` | iTerm2 prefs |

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

## Shell Functions

- `@` — `cd ~/src` or `cd ~/src/<fuzzy-match>`
- `@pr` — open GitHub PR for current branch in browser
- `rubylint` — run `rubocop -a` on git-changed Ruby files only
- `swo` — recover vim swap files and open originals
