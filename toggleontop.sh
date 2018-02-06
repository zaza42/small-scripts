#!/bin/sh
[ $(xprop -id $(xdotool getactivewindow) _WIN_LAYER|sed -e 's/.* //') = 4 ] && icesh -window focus setLayer 6 || icesh -window focus setLayer 4
