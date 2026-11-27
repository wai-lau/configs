precmd() {
  local ec=$?
  local ssh_part=""
  [[ -n "$SSH_CLIENT" ]] && ssh_part="%F{yellow}[ssh:%m]%f "
  local star
  if (( ec == 0 )); then
    star="%F{green}✦%f"
  elif (( ec == 1 )); then
    star="%F{red}✦%f"
  else
    star="%F{red}${ec} ✦%f"
  fi
  local user_part
  if [[ "$USER" == wai || "$USER" == wai-root || "$USER" == root ]]; then
    user_part="%K{255}%F{0} %n %f%k "
  else
    user_part="%F{208}%n%f "
  fi
  PS1="${user_part}%F{#FFB5C8}[%D{%H:%M}]%f ${ssh_part}%F{#F5EDD8}%2~%f ${star} "
}

# Sources
[[ "$(uname)" == "Linux" ]] && eval "$(dircolors -b)"
source $HOME/.alias.zsh
source $HOME/.local.zsh
[ -f ~/.secrets ] && source ~/.secrets

# PATH
export GOPATH=$HOME/go
export PATH=$HOME/bin:$PATH
export PATH=$HOME/.local/bin:$PATH
# /usr/local/bin LAST so its `claude` session-cap wrapper wins over the native
# ~/.local/bin/claude symlink (only `claude` lives in /usr/local/bin, nothing else shifts)
export PATH=/usr/local/bin:$PATH
export PATH=$HOME/.vim/bundle/fzf/bin:$PATH
[[ -d $HOME/go/bin ]]   && export PATH=$HOME/go/bin:$PATH
[[ -d $HOME/.rbenv ]]   && export PATH=$HOME/.rbenv/bin:$PATH
[[ -d /home/linuxbrew ]] && export PATH=/home/linuxbrew/.linuxbrew/bin:$PATH

# Environment
export GITHUB_USER=wai-lau
export GO111MODULE=on
export TERM=screen-256color
export COLORTERM=truecolor

# History
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt appendhistory

# Completion
zcompdump="${ZDOTDIR:-$HOME}/.zcompdump"
autoload -Uz compinit
compinit -C
zmodload -i zsh/complist

# FZF
export FZF_DEFAULT_COMMAND="find . -path '*/\.*' -type d -prune -o -type f -print -o -type l -print 2> /dev/null | sed s/^..//"
export FZF_DEFAULT_OPTS="-i"
source ~/.vim/bundle/fzf/shell/key-bindings.zsh

# Keybindings
bindkey -e
bindkey -r "^V"
bindkey "\e[3~" delete-char

# System
ulimit -n 10240
# WSL-only: Windows Chrome as $BROWSER (absent on droplet)
[[ -d /mnt/c ]] && export BROWSER="/mnt/c/Program Files/Google/Chrome/Application/chrome.exe"
# gated: pass (password-store) not on every host
command -v pass >/dev/null && export GH_TOKEN=$(pass show github/token)

# Interactive claude wrapper: auto-update, then launch with ~/.claude/private.md
# as appended system prompt. Skip both for `claude -p` / `claude --print`.
claude() {
    # In the emet repo, route to the walled `claude` dev account (kernel wall
    # keeps it out of data/). Gate: not already that account, and the walled
    # checkout exists (WSL-only; droplet $HOME=/root has no /home/wai/src/emet).
    if [[ "$USER" != claude && ( "$PWD" == /home/wai/src/emet || "$PWD" == /home/wai/src/emet/* ) ]]; then
        safeclaude "$@"
        return
    fi
    local arg has_p=0
    for arg in "$@"; do
        if [[ "$arg" == "-p" || "$arg" == "--print" ]]; then
            has_p=1
            break
        fi
    done
    # -p/--print: one-shot, no private.md, no relaunch loop.
    if (( has_p )); then
        command claude "$@"
        return
    fi
    # Auto-update before every interactive launch so this session runs the
    # latest build (~2s when already current). Background updater is off
    # (autoUpdates=false in ~/.claude.json), so this is the only update path.
    # timeout guards offline hosts; a failed check never blocks launch.
    # Sits above the loop: /purge relaunches skip it.
    timeout 20 claude update || true
    # A bare `claude` in a git repo under ~/src starts mates there: a lead with
    # Qwen panes, crash resume, terminal reset (Wai, 2026-11-18: "claude command
    # should run mates"). Arguments, anywhere else, or a Qwen worktree: plain
    # claude below. `command claude` is always plain.
    local top
    if (( $# == 0 )) && [[ -z "${MATES_LEAD:-}" ]] && [[ -x "$HOME/bin/mates" ]] \
        && top=$(git rev-parse --show-toplevel 2>/dev/null) \
        && [[ "$top" == "$HOME"/src/?* && "$top" != */.claude/worktrees/* ]]; then
        "$HOME/bin/mates"
        return
    fi
    # Interactive: relaunch loop powering /purge and /restart. Plain Ctrl+D
    # quits (no sentinel). First launch honors "$@".
    # /purge drops ~/.claude/.purge then SIGTERMs this process; on exit we wipe
    # the sentinel and relaunch a fresh instance, bare, for a pristine session.
    # /restart (~/.claude/restart.sh) writes ~/.claude/.restart.<this shell's
    # pid> (line 1: session id, rest: first prompt), then SIGKILLs claude so its
    # background tasks live on; we relaunch `claude --resume <id>` on the latest
    # build. CLAUDE_WRAPPER_PID tells restart.sh this loop is here to do that.
    # The file is also read at launch: for a shell that ran an older wrapper,
    # restart.sh types `source ~/.zshrc && claude` into the tmux pane.
    local -a launch_args=("$@") restart
    local restart_file="$HOME/.claude/.restart.$$"
    # Prompt bar color: this pane runs on its own theme, which the statusline
    # (~/.claude/statusline-command.sh) recolors to the session's title bar.
    local pane_theme="pane-$$"
    local theme_file="$HOME/.claude/themes/$pane_theme.json"
    mkdir -p "$HOME/.claude/themes"
    # A closed pane kills its shell before the rm below runs: prune the
    # themes of shells that are gone.
    local f
    for f in "$HOME"/.claude/themes/pane-*.json(N); do
        kill -0 "${${f:t:r}#pane-}" 2>/dev/null || rm -f "$f"
    done
    [[ -f "$theme_file" ]] || printf '{"name":"%s","base":"dark","overrides":{}}\n' "$pane_theme" > "$theme_file"
    while true; do
        if [[ -f "$restart_file" ]]; then
            # Over 10 minutes old: a relaunch that never ran; drop it.
            if [[ -n "$(find "$restart_file" -mmin -10 2>/dev/null)" ]]; then
                restart=("${(@f)$(<"$restart_file")}")
                launch_args=(--resume "${restart[1]}" -- "${(F)restart[2,-1]}")
            fi
            rm -f "$restart_file"
        fi
        if [[ -r "$HOME/.claude/private.md" ]]; then
            CLAUDE_WRAPPER_PID=$$ MIMALLOC_PURGE_HOLES=0 command claude --settings "{\"theme\":\"custom:$pane_theme\"}" --append-system-prompt "$(<"$HOME/.claude/private.md")" "${launch_args[@]}"
        else
            CLAUDE_WRAPPER_PID=$$ MIMALLOC_PURGE_HOLES=0 command claude --settings "{\"theme\":\"custom:$pane_theme\"}" "${launch_args[@]}"
        fi
        # However claude ended (a SIGKILL from /restart, a crash such as Bun's
        # segfault), it may have left the terminal raw, on the alt screen with
        # the cursor hidden and paste/focus/mouse/kitty-key modes on: mouse moves
        # then type junk and Ctrl+C arrives as an escape code. MIMALLOC_PURGE_HOLES=0
        # above turns off the allocator step Bun 1.4.4 segfaulted in (2026-11-18).
        stty sane 2>/dev/null
        printf '\033[?1049l\033[?25h\033[0m\033[?2004l\033[?1004l\033[?1000l\033[?1002l\033[?1003l\033[?1006l\033[<100u\033[=0;1u\033[>4m'
        if [[ -f "$restart_file" ]]; then
            timeout 20 claude update || true
            continue
        fi
        [[ -f "$HOME/.claude/.purge" ]] || break
        rm -f "$HOME/.claude/.purge"
        launch_args=()
        stty sane 2>/dev/null
        printf '\033[?1049l\033[?25h\033[0m'
    done
    rm -f "$theme_file"
}

# Ollama (for aider, etc.)
export OLLAMA_API_BASE=http://127.0.0.1:11434
export OLLAMA_CONTEXT_LENGTH=8192

# caveman plugin default intensity (highest-priority resolver source)
export CAVEMAN_DEFAULT_MODE=ultra

# pace-snooze ? (status): zsh would glob the bare `?`, so no globbing for this command
alias pace-snooze='noglob pace-snooze'

# bare `tmux`: attach to the existing session (boot server / resurrect), else make one.
# Any args pass straight through.
tmux() {
  if (( $# )); then command tmux "$@"
  else command tmux attach 2>/dev/null || command tmux new-session
  fi
}

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# WSL: the first terminal opened attaches to the boot tmux server, so it
# runs in front instead of only in the background. Tabs opened after that
# get a plain shell (no mirrored second client). Skip inside tmux, over
# ssh, in VS Code, and without a tty.
if [[ -d /mnt/c && -z $TMUX && -z $SSH_CONNECTION && $TERM_PROGRAM != vscode \
      && -o interactive && -t 0 && -t 1 ]] \
   && [[ -z $(command tmux list-clients 2>/dev/null) ]]; then
  tmux
fi
