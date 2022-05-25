source $HOME/.alias.zsh    # load aliases
source $HOME/.local.zsh    # load environment variables and secret keys

# load cb-zsh
[ -f $(brew --prefix cb-zsh 2>/dev/null)/config.zsh ] && source $(brew --prefix cb-zsh)/config.zsh

# load fuzzyhub
[ -f $(brew --prefix fuzzyhub 2>/dev/null)/fuzzyhub.zsh ] && source $(brew --prefix fuzzyhub)/fuzzyhub.zsh

bindkey -e
bindkey -r "^V"
bindkey "\e[3~" delete-char

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export PATH=/usr/local/bin:$PATH

alias pip='pip3'
alias python='python3'
alias vim!='sudo vim'
alias kk='kctx'
alias kc='kubectl config current-context'
alias colocon='vim ~/.vim/bundle/vim-colorschemes/colors'
alias alacon='vim ~/.config/alacritty/alacritty.yml'
alias g=git
alias k=kubectl
alias dc='docker-compose'

export XDG_CONFIG_HOME=~/.config
export EDITOR=/usr/bin/vim

autoload -U compinit && compinit
zmodload -i zsh/complist

HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt appendhistory

export FZF_DEFAULT_COMMAND="find . -path '*/\.*' -type d -prune -o -type f -print -o -type l -print 2> /dev/null | sed s/^..//"

[[ -x /usr/local/bin/brew ]] && eval $(/usr/local/bin/brew shellenv)

[[ -x /opt/homebrew/bin/brew ]] && eval $(/opt/homebrew/bin/brew shellenv)

# Ruby
eval "$(rbenv init -)"

# Go
eval "$($(go env GOPATH)/bin/assume-role -init)"
export GO111MODULE=on
export GOPROXY=https://gomodules.example.com/
export GONOSUMDB=github.example.com
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$PATH

# assume-role
# ———————————
[ -f $GOPATH/bin/assume-role ] && eval "$($GOPATH/bin/assume-role -init)"

export MONOREPO_PATH="/Users/wai/src/repo"
export MY_JIRA_BOARD="https://jira.example.com/secure/RapidBoard.jspa?rapidView=1505&projectKey=DEPLOY"
source $MONOREPO_PATH/scripts/rc/rc.sh
eval "ssh-add -A 2>/dev/null;"
