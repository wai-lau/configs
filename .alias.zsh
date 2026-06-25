export EDITOR='vim'

# editing config
alias ez="$EDITOR ~/.zshrc"       # alias for Edit Zshrc
alias sz="source ~/.zshrc"
alias ea="$EDITOR ~/.alias.zsh"   # alias for Edit Alias
alias el="$EDITOR ~/.local.zsh"   # alias for Edit Local

alias @x="ssh -t root@wai-lau.net 'tmux new-session -As shared'"
alias @z="mosh root@wai-lau.net -- zsh"


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
  # Browser opener per host: WSL-local (/mnt/c) → Windows browser via
  # wslview; local Linux desktop → xdg-open; over SSH / headless droplet
  # → print the URL to copy (no usable local browser there).
  local -a opener
  if [[ -d /mnt/c ]]; then
    opener=(wslview)
  elif [[ -z "$SSH_CONNECTION" ]] && command -v xdg-open >/dev/null; then
    opener=(xdg-open)
  else
    opener=(print -r --)
  fi
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
      ${opener[@]} https://github.com/$upstream_repo_name/compare/$(git rev-parse --abbrev-ref HEAD)\?expand=1
    else
      ${opener[@]} https://github.com/$upstream_repo_name/compare/master...$GITHUB_USER:$(git rev-parse --abbrev-ref HEAD)\?expand=1
    fi
  else
    ${opener[@]} https://github.com/$upstream_repo_name/pull/$pr_number
  fi
}


alias ls='ls -a --color=auto'

alias tags='ctags -R .'
alias g='git'

