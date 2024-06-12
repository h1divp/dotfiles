#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '

# Aliases
alias calc="qalc"
alias de="dict -d !"
alias myip="curl -w '\n' ipinfo.io/ip"
# alias ranger='ranger --choosedir=$HOME/.rangerdir; LASTDIR=`cat $HOME/.rangerdir`; cd "$LASTDIR"'
alias r='ranger --choosedir=$HOME/.rangerdir; LASTDIR=`cat $HOME/.rangerdir`; cd "$LASTDIR"'
alias t='bpytop'
alias p='pulsemixer'
alias l='eza'
alias c='bat'
alias n='nmcli'
alias xx="xset r rate 220 60"
alias hx="helix"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

# Add dirs to PATH
export PATH=/home/phoenix/Documents/Apps/pycharm-community-2022.2.1/bin:/usr/local/bin/fennel-1.2.1:/home/phoenix/.config/nvim/bin:$PATH

# Wine
export MESA_LOADER_DRIVER_OVERRIDE=crocus
