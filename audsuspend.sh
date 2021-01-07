#!/bin/lksh
#audacious on desktop number
audesktop=1
audplugins=(blur_scope cairo-spectrum albumart gl-spectrum)

source ~/scripts/mytime.inc
source ~/scripts/mykill.inc

#dunstify -a audsuspend indul
pidfile=/dev/shm/audsuspend.pid
xpidfile=/dev/shm/audsuspend-xinput.pid
[ -f $pidfile ] && exit || echo $$ > $pidfile
trap "rm $pidfile $xpidfile; exit" SIGHUP SIGINT SIGTERM EXIT

audpid=$(pidof audacious)

xprop -spy -root _NET_CURRENT_DESKTOP | while read -r _ _ curdesk;do
#	mytime curdesk="$curdesk"
    case $curdesk in
	$audesktop)
            for p in ${audplugins[@]};
                do audtool plugin-is-enabled $p || audtool plugin-enable $p
            done
	    plugins=1
	    if ! icesh -W this -c audacious.Audacious id &>/dev/null; then
		xdotool mousemove --sync $(icesh xembed|sed -n '/Audacious/ s/.*24x24+\([0-9]*\)+\([0-9]*\)/\1 \2/g p') click --clearmodifiers 1 mousemove restore #'

		if xinput query-state 12|grep -q 'key\[64\]=up' ;then
		    xdotool keyup Alt
		    return
		fi
		[ -f $xpidfile ] && exit
		(xinput test 12 & echo $! >&3 ) 3>$xpidfile |
		    while read line;do
    			if [[ $line = 'key release 64' ]]; then
        		    xdotool keyup Alt
        		    mykill -9 $(<$xpidfile)
    			fi
		    done
		rm $xpidfile
	    fi
	;;
	[0-9])
	    [[ $plugins = 1 ]] &&
        	for p in ${audplugins[@]};
            	    do audtool plugin-is-enabled $p && audtool plugin-enable $p off
        	done
	    plugins=0
	;;
    esac
    if ! [[ $(</proc/$audpid/cmdline) = *audacious* ]]; then
	    echo audsuspend.sh exits
	    mypid=$(<$pidfile)
	    rm $pidfile
	    mykill -9 $mypid
	    exit
    fi
done
