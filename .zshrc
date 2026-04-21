export PS1="%F{#FFB5C8}[%D{%H:%M}]%f %F{#F5EDD8}%2~%f %F{blue}✦%f "

# Sources
[[ "$(uname)" == "Linux" ]] && eval "$(dircolors -b)"
source $HOME/.alias.zsh
source $HOME/.local.zsh
[ -f ~/.secrets ] && source ~/.secrets

# PATH
export GOPATH=$HOME/go
export PATH=/usr/local/bin:$PATH
export PATH=$HOME/go/bin:$PATH
export PATH=$HOME/.vim/bundle/fzf/bin:$PATH
export PATH=$HOME/.rbenv/bin:$PATH
export PATH=$HOME/.local/bin:$PATH

# Environment
export EDITOR=/usr/bin/vim
export GITHUB_USER=wailun-lau
export GO111MODULE=on
export TERM=screen-256color

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

# Aliases
alias pip='pip3'
alias spec='bundle exec rspec'
alias python='python3'
alias vim!='sudo vim'
alias colocon='vim ~/.vim/bundle/vim-colorschemes/colors'
alias alacon='vim ~/.config/alacritty/alacritty.yml'
alias g=git
alias k=kubectl
alias dc='docker-compose'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias klv='top -l 1 | grep dlv | awk "{print $1;}" | xargs kill'
alias version:='echo $(zsh --version)'
alias swp='find . -name ".*.swp"; find . -name ".*.swo"; find . -name "**/.*.swp"; find . -name "**/.*.swo"'
alias swp!='find . -name ".*.swp" -delete; find . -name ".*.swo" -delete; find . -name "**/.*.swp" -delete; find . -name "**/.*.swo" -delete'
alias pbc='/mnt/c/Windows/System32/clip.exe'
alias obsidian='/mnt/c/Users/wailu/AppData/Local/Programs/Obsidian/Obsidian.com'

# Functions
swo () {
  found=$(find . -name ".*.swp")
  found=$found\ $(find . -name ".*.swo")
  found=$found\ $(find . -name "**/.*.swp")
  found=$found\ $(find . -name "**/.*.swo")
  local original
  while IFS= read -r swp; do
    echo "Recovering: $swp"
    swp="${swp//$'\n'/}"
    swp="${swp//$'\r'/}"
    swp="${swp// /}"
    base=$(basename $swp)
    vim -r "$swp" -c "wq" </dev/tty > /dev/null 2>&1
    rm $swp

    dir=$(dirname $swp)
    base="${base%.*}"
    if [[ -e "$dir/$base" ]]; then
    echo "File exists. Performing something..."
    else
      base="${base:1}"
    fi
    original="$original $dir/$base"
  done <<< "$found"
  vim -O ${${${original//$'\n'/ }:1}[@]}
}

rubylint () {
FILES=()
while IFS= read -r file; do
  FILES+=("$file")
done < <(git diff --name-only --diff-filter=ACMRTUXB HEAD | grep '\.rb$' || true)

if [ ${#FILES[@]} -eq 0 ]; then
  echo "No Ruby files changed."
fi

echo "Running rubocop on the following files:"
printf '%s\n' "${FILES[@]}"

for FILE in "${FILES[@]}"; do
  if [ -f "$FILE" ]; then
    echo "→ $FILE"
    bundle exec rubocop -a "$FILE"
  else
    echo "⚠️  Skipping missing file: $FILE"
  fi
done
}

# System
ulimit -n 10240
