bindkey -e
# load dev, but only if present and the shell is interactive
if [[ -f /opt/dev/dev.sh ]] && [[ $- == *i* ]]; then
  source /opt/dev/dev.sh
fi

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
eval "$(shadowenv init zsh)"
export PATH=/usr/local/bin:$PATH
alias pip='pip3'
alias python='python3'
export XDG_CONFIG_HOME=~/.config
. /usr/local/lib/python3.7/site-packages/powerline/bindings/zsh/powerline.zsh
export EDITOR=/usr/bin/vim
alias k=kubectl
autoload -U compinit && compinit
zmodload -i zsh/complist

bindkey "\e[3~" delete-char
alias "dev testall"="source dev.sh && TERM=color dev test SUITE=all"
alias vim="vim 2>/dev/null"
export GOPATH=/Users/wai
export FZF_DEFAULT_COMMAND="find . -path '*/\.*' -type d -prune -o -type f -print -o -type l -print 2> /dev/null | sed s/^..//"

HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt appendhistory

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/wai/Downloads/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/wai/Downloads/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/wai/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/wai/Downloads/google-cloud-sdk/completion.zsh.inc'; fi

export PATH=$GOPATH/bin:$PATH
