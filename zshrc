
# The following lines were added by compinstall

zstyle ':completion:*' completer _complete _ignored _approximate
zstyle :compinstall filename '/home/phoenix/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall
# Lines configured by zsh-newuser-install
HISTFILE=~/.zshhistfile
HISTSIZE=1000
SAVEHIST=1000
setopt autocd extendedglob nomatch notify
unsetopt beep
bindkey -v
# End of lines configured by zsh-newuser-install

autoload -Uz promptinit && promptinit
prompt suse

eval "$(zoxide init zsh)"

zstyle ':completion:*' rehash true

alias ls='ls --color=auto'

# Aliases
alias calc="qalc"
alias de="dict -d !"
alias myip="curl -w '\n' ipinfo.io/ip"
# alias r='ranger --choosedir=$HOME/.rangerdir; LASTDIR=`cat $HOME/.rangerdir`; cd "$LASTDIR"'
alias t='btop'
# alias tt='trash-restore'
alias p='pulsemixer'
alias ls='eza'
alias cat='bat'
alias n='nmcli'
alias nrefresh='nmcli dev wifi rescan && nmcli dev wifi list'
alias xx="xset r rate 220 60"
alias hx="helix"
alias spotify="spotify_player"
alias s="nsxiv -a ./ "
alias sf="shuf -e ./* | nsxiv - -a "
alias kk="killall -q"
alias rsh="pkill -USR1 redshift"
alias thr="LC_ALL=ja_JP.utf8 prime-run wine "
alias recon="nmcli radio wifi off && nmcli radio wifi on && nmcli device reapply wlp0s20f3"
alias mcd="sudo mount /dev/mmcblk0p1 /mnt/ && cd /mnt"
alias zz="du -hs"
alias pomo="termato --focus 40 --short-break 10 --notify \"notify-send 'termato: %s' && mpv ~/Media/chimes.wav --loop=no --no-terminal &\""
alias ww=".scripts/toggle_wifi"
alias runproton="~/.scripts/runwithproton"
alias rip="cdda2wav -vall cddb=-1 speed=4 -paranoia paraopts=proof -B -D /dev/sr0 && for i in *.wav; do flac \$i; done && mkdir .rip && mv *.wav *.inf .rip"
alias bb="systemctl --user start otd.service"
alias dp1flip="~/.scripts/dp1_flip"
alias dp1con="~/.scripts/dp1_con"
alias dp1dcon="~/.scripts/dp1_dcon"
alias hdmicon="~/.scripts/hdmi_con"
alias dreset="~/.scripts/reset-display"
alias nrip="yt-dlp --add-metadata"
alias convert="magick"
function cpr() {
  rsync --archive -hh --partial --info=stats1,progress2 --modify-window=1 "$@"
} 
function mvr() {
  rsync --archive -hh --partial --info=stats1,progress2 --modify-window=1 --remove-source-files "$@"
}

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

# Add dirs to PATH
export PATH=/home/phoenix/Documents/Apps/pycharm-community-2022.2.1/bin:/usr/local/bin/fennel-1.2.1:/home/phoenix/.config/nvim/bin:/home/phoenix/.local/bin:$PATH

# Wine
export MESA_LOADER_DRIVER_OVERRIDE=crocus

# Prevent games from dissapearing on fullscreen
export SDL_VIDEO_MINIMIZE_ON_FOCUS_LOSS=0

# yazi
function r() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

### git: Show marker (T) if there are untracked files in repository
# Make sure you have added staged to your 'formats':  %c
# autoload -Uz vcs_info

# precmd() { vcs_info }
# # This needs prompt_subst set, hence the name. So:
# setopt prompt_subst
# # PS1='%!-%3~ ${vcs_info_msg_0_}%# '

# zstyle ':vcs_info:git*+set-message:*' hooks git-untracked

# +vi-git-untracked(){
#     if [[ $(git rev-parse --is-inside-work-tree 2> /dev/null) == 'true' ]] && \
#         git status --porcelain | grep -q '^?? ' 2> /dev/null ; then
#         # This will show the marker if there are any untracked files in repo.
#         # If instead you want to show the marker only if there are untracked
#         # files in $PWD, use:
#         #[[ -n $(git ls-files --others --exclude-standard) ]] ; then
#         hook_com[staged]+='T'
#     fi
# }

# setopt prompt_subst
# autoload -Uz vcs_info
# zstyle ':vcs_info:*' actionformats \
#     '%F{5}(%f%s%F{5})%F{3}-%F{5}[%F{2}%b%F{3}|%F{1}%a%F{5}]%f '
# zstyle ':vcs_info:*' formats       \
#     '%F{5}(%f%s%F{5})%F{3}-%F{5}[%F{2}%b%F{5}]%f '
# zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat '%b%F{1}:%F{3}%r'

# zstyle ':vcs_info:*' enable git cvs svn

# # or use pre_cmd, see man zshcontrib
# vcs_info_wrapper() {
#   vcs_info
#   if [ -n "$vcs_info_msg_0_" ]; then
#     echo "%{$fg[grey]%}${vcs_info_msg_0_}%{$reset_color%}$del"
#   fi
# }
# RPROMPT=$'$(vcs_info_wrapper)'

