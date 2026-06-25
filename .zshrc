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
    star="%F{red}${ec}✦%f"
  fi
  PS1="%F{#FFB5C8}[%D{%H:%M}]%f ${ssh_part}%F{#F5EDD8}%2~%f ${star} "
}

# Sources
[[ "$(uname)" == "Linux" ]] && eval "$(dircolors -b)"
source $HOME/.alias.zsh
source $HOME/.local.zsh
[ -f ~/.secrets ] && source ~/.secrets

# PATH
export GOPATH=$HOME/go
export PATH=/usr/local/bin:$PATH
export PATH=$HOME/bin:$PATH
export PATH=$HOME/.local/bin:$PATH
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

# Inject ~/.claude/private.md as appended system prompt for interactive
# claude sessions only. Skip for `claude -p` / `claude --print`.
claude() {
    local arg has_p=0
    for arg in "$@"; do
        if [[ "$arg" == "-p" || "$arg" == "--print" ]]; then
            has_p=1
            break
        fi
    done
    if (( has_p )) || [[ ! -r "$HOME/.claude/private.md" ]]; then
        command claude "$@"
    else
        command claude --append-system-prompt "$(<"$HOME/.claude/private.md")" "$@"
    fi
}

# Ollama (for aider, etc.)
export OLLAMA_API_BASE=http://127.0.0.1:11434
export OLLAMA_CONTEXT_LENGTH=8192

# caveman plugin default intensity (highest-priority resolver source)
export CAVEMAN_DEFAULT_MODE=ultra
