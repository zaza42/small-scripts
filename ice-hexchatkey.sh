#!/bin/lksh
#minimize/restore hexchat to/from systray with icewm keycombo
#
# by DC-1
# 2021.01.07.
#
#~/.icewm/keys
#key "Alt+d" hexchatkey.sh
#
# required binaries:
# icesh, xdotool, sed, xinput
#
# optional:
# Implement /proc/pid/kill to procfs, a.k.a. killpatch:
#      http://lkml.iu.edu/hypermail/linux/kernel/1810.3/03701.html#
#################################################################

xpidfile=/dev/shm/hexchatkey-xinput.pid

icesh -c hexchat minimize 2>/dev/null && exit

xdotool mousemove --sync $(icesh xembed|sed -n '/Hexchat/ s/.*24x24+\([0-9]*\)+\([0-9]*\)/\1 \2/g p') click --clearmodifiers 1 mousemove restore #'
if xinput query-state 12|grep -q 'key\[64\]=up' ;then
 xdotool keyup Alt
 exit
fi
[ -f $xpidfile ] && exit
#pgrep -f 'xinput test 12' >/dev/null && exit
(xinput test 12 & echo $! >&3 ) 3>$xpidfile|while read line;do
		    if [[ $line = 'key release 64' ]]; then
			xdotool keyup Alt
#			pkill -9 -f 'xinput test 12'
			echo 9 > /proc/$(<$xpidfile)/kill #killpatch
#			kill -9 $(<$xpidfile)
		    fi
	       done
rm $xpidfile
