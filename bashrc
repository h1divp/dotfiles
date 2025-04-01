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
# alias proton="PROTONPATH=\"/home/phoenix/.steam/steam/steamapps/common/Proton 6.3\" GAMEID=0 umu-run"
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
alias vps="~/.scripts/ssh_into_vps"
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
