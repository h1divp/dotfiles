source /usr/share/cachyos-fish-config/cachyos-config.fish

# overwrite greeting
# potentially disabling fastfetch
function fish_greeting
    fastfetch --config examples/27
end

setenv GTK_IM_MODULE fcitx5
setenv QT_IM_MODULE fcitx5
setenv XMODIFIERS @im=fcitx5
set -gx XDG_SCREENSHOTS_DIR "$HOME/Media/Screenshots" # also in sway config
set -x GOPATH $HOME/go
set -x PATH $PATH $GOPATH/bin
set -x PATH $PATH /home/h1divp/.local/share/gem/ruby/3.4.0/bin
set -x PATH $PATH /usr/bin/

alias hx helix
alias de dict
alias calc qalc
alias reptilian-start "VBoxManage startvm vm --type headless"
alias reptilian-stop "VBoxManage controlvm vm poweroff"
alias onlyoffice-desktopeditors "/usr/bin/onlyoffice-desktopeditors --force-scale=1.2"
