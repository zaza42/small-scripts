#!/bin/lksh
if [ "$1" = "stop" ] || [ "$1" = "off" ]; then
    winpos.sh run xrandr --output VGA-0 --off
#    xrandr --output DisplayPort-1 --off --output LVDS --primary --mode 1600x900 --pos 0x0 --rotate normal --output VGA-0 --mode 1600x900x60.2 --pos 0x0 --rotate normal --output DisplayPort-0 --off
#    killall dunst; dunst &
else
#    killall dunst
    winpos.sh run xrandr --output DisplayPort-1 --off --output LVDS --primary --mode 1600x900 --pos 0x0 --rotate normal --output VGA-0 --mode 800x600 --pos 1600x0 --rotate normal --output DisplayPort-0 --off
fi
