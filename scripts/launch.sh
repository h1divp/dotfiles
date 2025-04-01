#! /bin/bash

# Terminate already running bar instances (and Compton)
# killall -q polybar
# killall -q cava

# Wait until the processes have been shut down
# while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Launch bar
# polybar top &

#  For external monitors, external bar tbd
 # if [[ $(xrandr -q | grep 'HDMI-1 connected') ]]; then
    # polybar top_secondary &
 # fi

# --- New launch script ---
# Terminate already running bar instances
# If all your bars have ipc enabled, you can use 
polybar-msg cmd quit
# Otherwise you can use the nuclear option:
# killall -q polybar

# Launch bar1 and bar2
echo "---" | tee -a /tmp/polybar1.log /tmp/polybar2.log
polybar top 2>&1 | tee -a /tmp/polybar1.log & disown
polybar top_secondary 2>&1 | tee -a /tmp/polybar2.log & disown

echo "Bars launched..."
