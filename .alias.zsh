export EDITOR='vim'

# editing config
alias ez="$EDITOR ~/.zshrc"       # alias for Edit Zshrc
alias ea="$EDITOR ~/.alias.zsh"   # alias for Edit Alias
alias el="$EDITOR ~/.local.zsh"   # alias for Edit Local

@() {
  if [ -z "$@" ]
  then
    cd ~/src
  else
    cd "$HOME/src/$(ls ~/src | grep $1 -m 1)"
  fi
}

@pr() {
  local upstream_repo_name
  if [[ $(git config remote.origin.url) == *"@"* ]]; then
    if [[ $(git config remote.origin.url) == *".git" ]]; then
      upstream_repo_name=${"$(cut -d ':' -f 2- <<< "$(git config remote.origin.url)")": :(-4)}
    else
      upstream_repo_name="$(cut -d ':' -f 2- <<< "$(git config remote.origin.url)")"
    fi
  else
    if [[ $(git config remote.origin.url) == *".git" ]]; then
      upstream_repo_name=${"$(cut -d '/' -f 4- <<< "$(git config remote.origin.url)")": :(-4)}
    else
      upstream_repo_name="$(cut -d '/' -f 4- <<< "$(git config remote.origin.url)")"
    fi
  fi

  local pr_number=$(
    cut -d$'\t' -f 1 <<< "$(
      gh pr --state all --repo $upstream_repo_name --author $GITHUB_USER list | grep -m 1 $(git rev-parse --abbrev-ref HEAD)
    )"
  )

  if [ -z "$pr_number" ]
  then
    if [[ $(git config remote.origin.url) == $(git config remote.origin.url) ]]; then
      open https://github.example.com/$upstream_repo_name/compare/$(git rev-parse --abbrev-ref HEAD)\?expand=1
    else
      open https://github.example.com/$upstream_repo_name/compare/master...$GITHUB_USER:$(git rev-parse --abbrev-ref HEAD)\?expand=1
    fi
  else
    open https://github.example.com/$upstream_repo_name/pull/$pr_number
  fi
}

alias dash="~/dash"
alias sz='exec zsh'
alias ls='ls -G'

alias fco='fh checkout'
alias fcop='fh checkout-pr'
alias fsm='fh sync-master'
alias fpr='fh view-pr'
alias fm='fh view-master'
alias fl='fh view-local'

alias tags='ctags -R .'
alias g='git'

alias vpnwifi='networksetup -setdhcp Wi-Fi'
alias vpndata='networksetup -setmanual Wi-Fi 172.20.10.3 255.255.255.240 172.20.10.1'
