#!/bin/sh
id=$(xdotool getactivewindow)
windesk=$(xdotool get_desktop_for_window $id 2>/dev/null)
#echo id: $id curdesk: $curdesk windesk: $windesk
if [ "$windesk" = "-1" ]; then
    curdesk=$(xdotool get_desktop)
    icesh -window $id setWorkspace $curdesk
else
    icesh -window $id setWorkspace 0xFFFFFFFF
fi
