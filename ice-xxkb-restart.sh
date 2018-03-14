#!/bin/lksh
source ~/scripts/mytime.inc
#restart xxkb after `icewm -r`
xprop -spy -root _WIN_SUPPORTING_WM_CHECK 2>/dev/null| while read a; do
#    echo "# $a"
    mytime "IceWM restart...restarting xxkb"
    if [ -n "$a" ]; then 
	pkill -x xxkb; sleep 0.5; xxkb & 
	sleep 1 && icesh -c claws-mail setState Hidden add
    fi
done
