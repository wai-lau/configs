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
