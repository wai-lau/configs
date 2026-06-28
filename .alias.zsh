# Aliases + utility functions. .zshrc sources this early.
# (Shell setup / env / tool wrappers live in .zshrc, not here.)

export EDITOR=/usr/bin/vim   # single source of truth; baked into ez/ea below

# ── Editing config ──
alias ez="$EDITOR ~/.zshrc"       # edit zshrc
alias sz="source ~/.zshrc"        # reload zshrc
alias ea="$EDITOR ~/.alias.zsh"   # edit aliases
alias el="$EDITOR ~/.local.zsh"   # edit machine-local

# ── Remote (droplet) ──
alias @x="ssh -t wai-root@wai-lau.net 'tmux new-session -As shared'"
alias @z="mosh wai-root@wai-lau.net -- zsh"

# ── Navigation ──
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# cd ~/src, or ~/src/<first fuzzy match>
@() {
  if [ -z "$@" ]; then
    cd ~/src
  else
    cd "$HOME/src/$(command ls ~/src | grep $1 -m 1)"
  fi
}

# ── Git ──
alias g='git'

# open the PR for the current branch (or the compare page if none yet)
@pr() {
  local upstream_repo_name
  # Browser opener per host: WSL-local (/mnt/c) -> Windows browser via
  # wslview; local Linux desktop -> xdg-open; over SSH / headless droplet
  # -> print the URL to copy (no usable local browser there).
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

  if [ -z "$pr_number" ]; then
    ${opener[@]} https://github.com/$upstream_repo_name/compare/$(git rev-parse --abbrev-ref HEAD)\?expand=1
  else
    ${opener[@]} https://github.com/$upstream_repo_name/pull/$pr_number
  fi
}

# ── Files / search ──
alias ls='ls -a --color=auto'
alias tags='ctags -R .'
alias swp='find . -name ".*.swp"; find . -name ".*.swo"; find . -name "**/.*.swp"; find . -name "**/.*.swo"'
alias swp!='find . -name ".*.swp" -delete; find . -name ".*.swo" -delete; find . -name "**/.*.swp" -delete; find . -name "**/.*.swo" -delete'

# ── Tooling (some tools are per-host; alias harmless if absent) ──
alias pip='pip3'
alias python='python3'
alias spec='bundle exec rspec'
alias vim!='sudo vim'
alias colocon='vim ~/.vim/bundle/vim-colorschemes/colors'
alias k=kubectl
alias dc='docker-compose'

# ── emet (knowledge graph; WSL-local only, ~/src/emet present) ──
# export current graph -> JSON, scp to droplet's password-gated route
[[ -d ~/src/emet ]] && alias publish-emet='~/src/emet/deploy/publish_graph.sh'

# Enter the walled `claude` dev account inside ITS OWN emet checkout and
# launch Claude Code there. `claude` = restricted emetcode-group dev acct;
# the kernel wall keeps it out of data/. claude can't traverse /home/wai
# (mode 750, group wai), so its repo is /home/claude/src/emet -- single-
# quote the body so `~` expands to claude's home in the login shell, not
# wai's. `sudo -i` loads claude's PATH; `exec` drops back to wai on quit.
# Args forwarded: trailing `bash "$@"` sets $0=bash so "$@" fills the -c
# script's positionals, e.g. `safeclaude -p '...'` reaches the walled claude.
# The `claude()` wrapper in .zshrc auto-routes here when cwd is in ~/src/emet.
safeclaude() { sudo -u claude -i bash -lc 'cd /home/wai/src/emet && exec claude "$@"' bash "$@"; }

# ── Functions ──

# Recover vim swap files in cwd, then open the originals side by side.
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

# rubocop -a on the Ruby files changed vs HEAD.
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
