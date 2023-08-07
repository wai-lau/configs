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
export PATH=$HOME/go/bin:$PATH

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

export XDG_CONFIG_HOME=~/.config
export EDITOR=/usr/bin/vim
export GITHUB_USER=wailun-lau

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

ssh-add /Users/wai/.ssh/work_key 2>/dev/null

# assume-role
# ———————————
[ -f $GOPATH/bin/assume-role ] && eval "$($GOPATH/bin/assume-role -init)"

export MONOREPO_PATH="/Users/wai/src/repo"
export MY_JIRA_BOARD="https://jira.example.com/secure/RapidBoard.jspa?rapidView=1505&projectKey=DEPLOY"
source $MONOREPO_PATH/scripts/rc/rc.sh

ulimit -n 10240

source $HOME/.alias.zsh    # load aliases
source $HOME/.local.zsh    # load environment variables and secret keys

# Brew
# ————
export PATH=/opt/homebrew/bin:$PATH

# Work
# ————————
export PATH="$HOME/.local/bin:$PATH"

acct () {
  cd ~/src/aws-resources
  git grep $1| grep account_id | awk -F'/' '{print $2}' | awk -F'.' '{print $1}'
  cd - > /dev/null
}

kdev () {
  assume-role core-codeflow-dev-use1 sudo-dev
  prev_ns=$(kubens -c)
  aws eks update-kubeconfig --name core-codeflow-dev-use1
  if [ ! -z "$@" ]; then
    echo "Switching to namespace containing $1"
    kubens $(k get ns | grep $1 -m 1 | awk '{print $1;}')
  fi
}

pods () {
  if [ -z "$@" ]; then
    watch kubectl get pods
  else
    kdev $@
    watch kubectl get pods
  fi
}

devup () {
read -d '' cmd << EOF
  source ~/.zshrc
  set -e
  ash_login
  make artifacts
  make docker-build > /dev/null 2>&1 &
  output=\$(bsx-builder local-deploy --config-file ./deployables/sif/development.yml | tee /dev/tty)
  if [ ! -z "\$(echo \$output | grep 'View Deploy status')" ]; then
    eval \$(echo \$output | grep 'ash deploy-status -d' | awk '{\$1=\$1};1')
  fi
EOF
  echo "${cmd}"
  zsh -c "${cmd}"
}


trig () {
  file="asdf"
  if [ -e "$file" ]; then
    # If the file exists, delete it
    rm "$file"
    git commit -am "remove"
    g ff
  else
    # If the file doesn't exist, create it with the text "test"
    echo "test" > "$file"
    git add -A
    git commit -am "add"
    g ff
  fi
}

logs () {
  if [ -z "$@" ]; then
		k logs -f $(kubectl get pods --sort-by=.status.startTime --no-headers | awk -v n=1 'NR == n { print $1 }')
  else
		k logs -f $(kubectl get pods --sort-by=.status.startTime --no-headers | awk -v n=$@ 'NR == n { print $1 }')
  fi
}

gofix() {
	golangci-lint run --fix
	git commit -am "golangci-lint run --fix"
}

