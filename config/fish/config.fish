source /usr/share/cachyos-fish-config/cachyos-config.fish

# overwrite greeting
# potentially disabling fastfetch
function fish_greeting
    fastfetch --config examples/27
end

setenv GTK_IM_MODULE fcitx5
setenv QT_IM_MODULE fcitx5
setenv XMODIFIERS @im=fcitx5
set EDITOR helix
set -gx XDG_SCREENSHOTS_DIR "$HOME/Media/Screenshots" # also in sway config
set -x GOPATH $HOME/.go
set -x PATH $PATH $GOPATH/bin
set -x PATH $PATH /home/h1divp/.local/share/gem/ruby/3.4.0/bin
set -x PATH $PATH /usr/bin/
set -x ANDROID_HOME /opt/android-sdk
set -x PATH $PATH $ANDROID_HOME/emulator
set -x PATH $PATH $ANDROID_HOME/platform-tools

alias hx helix
alias de dict
alias calc qalc
alias cat bat
alias reptilian-start "VBoxManage startvm vm --type headless"
alias reptilian-stop "VBoxManage controlvm vm poweroff"
alias onlyoffice-desktopeditors "/usr/bin/onlyoffice-desktopeditors --force-scale=1.2"

# quick cpp compile functions for competetive programming
function ccc
    g++ $argv; and ./a.out; and rm a.out
end

function cccrun
    g++ $argv; and ./a.out <input.txt >output.txt; and rm a.out
    diff output.txt expected.txt
end

# pnpm
set -gx PNPM_HOME "/home/h1divp/.local/share/pnpm"
if not string match -q -- $PNPM_HOME $PATH
    set -gx PATH "$PNPM_HOME" $PATH
end
