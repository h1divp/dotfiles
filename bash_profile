#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc

# User specific environment and startup programs
export EDITOR=helix
export SUDO_EDITOR=helix
export VISUAL="$EDITOR"

# Ranger
export RANGER_LOAD_DEFAULT_RC=FALSE

# For Japanese IME
export XMODIFIERS=@im=fcitx
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export GLFW_IM_MODULE=ibus
export SDL_IM_MODULE=fcitx
export PATH=$PATH:~/.config/i3/Scripts

# Qt themeing
export QT_QPA_PLATFORMTHEME=qt5ct
