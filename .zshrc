source $HOME/.alias.zsh    # load aliases
source $HOME/.local.zsh    # load environment variables and secret keys

# load cb-zsh
[ -f $(brew --prefix cb-zsh 2>/dev/null)/config.zsh ] && source $(brew --prefix cb-zsh)/config.zsh

# load fuzzyhub
[ -f $(brew --prefix fuzzyhub 2>/dev/null)/fuzzyhub.zsh ] && source $(brew --prefix fuzzyhub)/fuzzyhub.zsh

bindkey -e
bindkey -r "^V"
bindkey "\e[3~" delete-char

# [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

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
alias swp='find . -name ".*.swp"; find . -name ".*.swo"; find . -name "**/.*.swp"; find . -name "**/.*.swo"'
alias swp!='find . -name ".*.swp" -delete; find . -name ".*.swo" -delete; find . -name "**/.*.swp" -delete; find . -name "**/.*.swo" -delete'

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

export EDITOR=/usr/bin/vim
export GITHUB_USER=wailun-lau

# Speed up compinit
zcompdump="${ZDOTDIR:-$HOME}/.zcompdump"
autoload -Uz compinit
compinit -C
zmodload -i zsh/complist

HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt appendhistory

export FZF_DEFAULT_COMMAND="find . -path '*/\.*' -type d -prune -o -type f -print -o -type l -print 2> /dev/null | sed s/^..//"

# Brew
# ————
# PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/opt/homebrew/opt/zip/bin:/Users/wai/go/bin:/Users/wai/.pyenv/shims:/Users/wai/.local/bin:/usr/local/bin:/System/Cryptexes/App/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin:/usr/local/munki:/opt/salt:/Applications/iTerm.app/Contents/Resources/utilities"; export PATH;
export PATH=/opt/homebrew/bin:$PATH
# [[ -x /opt/homebrew/bin/brew ]] && eval $(/opt/homebrew/bin/brew shellenv)
export HOMEBREW_PREFIX="/opt/homebrew";
export HOMEBREW_CELLAR="/opt/homebrew/Cellar";
export HOMEBREW_REPOSITORY="/opt/homebrew";
fpath[1,0]="/opt/homebrew/share/zsh/site-functions";
[ -z "${MANPATH-}" ] || export MANPATH=":${MANPATH#:}";
export INFOPATH="/opt/homebrew/share/info:${INFOPATH:-}";

ssh-add /Users/wai/.ssh/work_key 2>/dev/null
ulimit -n 10240

# Work
# ————————
export PATH="$HOME/.local/bin:$PATH"

acct () {
  cd ~/src/aws-resources
  git grep $1| grep account_id | awk -F'/' '{print $2}' | awk -F'.' '{print $1}'
  cd - > /dev/null
}

# kdev () {
  # assume-role core-codeflow-dev-use1 sudo-dev
  # prev_ns=$(kubens -c)
  # aws eks update-kubeconfig --name core-codeflow-dev-use1
  # if [ ! -z "$@" ]; then
    # echo "Switching to namespace containing $1"
    # kubens $(k get ns | grep $1 -m 1 | awk '{print $1;}')
  # fi
# }

# pods () {
  # if [ -z "$@" ]; then
    # watch kubectl get pods
  # else
    # kdev $@
    # watch kubectl get pods
  # fi
# }

# devup () {
# read -d '' cmd << EOF
  # source ~/.zshrc
  # set -e
  # ash_login
  # make artifacts
  # make docker-build > /dev/null 2>&1 &
  # output=\$(bsx-builder local-deploy --config-file ./deployables/sif/development.yml | tee /dev/tty)
  # if [ ! -z "\$(echo \$output | grep 'View Deploy status')" ]; then
    # eval \$(echo \$output | grep 'ash deploy-status -d' | awk '{\$1=\$1};1')
  # fi
# EOF
  # echo "${cmd}"
  # zsh -c "${cmd}"
# }


# trig () {
  # file="asdf"
  # if [ -e "$file" ]; then
    # If the file exists, delete it
    # rm "$file"
    # git commit -am "remove"
    # g ff
  # else
    # If the file doesn't exist, create it with the text "test"
    # echo "test" > "$file"
    # git add -A
    # git commit -am "add"
    # g ff
  # fi
# }

# logs () {
  # if [ -z "$@" ]; then
    # k logs -f $(kubectl get pods --sort-by=.status.startTime --no-headers | awk -v n=1 'NR == n { print $1 }')
  # else
    # k logs -f $(kubectl get pods --sort-by=.status.startTime --no-headers | awk -v n=$@ 'NR == n { print $1 }')
  # fi
# }

# gofix() {
  # golangci-lint run --fix
  # git commit -am "golangci-lint run --fix"
# }

# Go
export GO111MODULE=on
export GOPROXY=https://gomodules.example.com/
export GONOSUMDB=github.example.com
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$PATH
export TERM=screen-256color

# assume-role
# ———————————
[ -f $GOPATH/bin/assume-role ] && eval "$($GOPATH/bin/assume-role -init)"

export JAVA_HOME=$(/usr/libexec/java_home -v 17)
eval "$(direnv hook zsh)"
export PATH="/opt/homebrew/opt/zip/bin:$PATH"

export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

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

export GITHUB_TOKEN=REDACTED_GITHUB_TOKEN
export GITHUB_API_URL=https://github.example.com/api/v3
export GITHUB_GRAPHQL_URL=https://github.example.com/api/graphql
export PATH=:/Users/wai/.rbenv/shims:/Users/wai/.rbenv/bin:/opt/homebrew/opt/zip/bin:/Users/wai/go/bin:/Users/wai/.local/bin:/opt/homebrew/bin:/Users/wai/go/bin:/usr/local/bin:/usr/local/bin:/System/Cryptexes/App/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin:/usr/local/munki:/opt/salt:/Applications/iTerm.app/Contents/Resources/utilities
