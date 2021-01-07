#!/bin/lksh
source ~/scripts/mytime.inc

spypid=/dev/shm/icefsspy.pid

typeset -l class class2 wmclass wmclass2
#typeset -l xsetparam=$(xset q|sed '/timeout/!d; s/^.*timeout:  \([0-9]*\).*cycle:  \([0-9]*\)$/s \1 \2s00/') #'
#xsstimeout=${xsetparam#* }
#xsstimeout=${xsstimeout% *}
typeset -l xsstimeout=$(xset q|sed '/timeout/!d; s/^.*timeout:  \([0-9]*\).*cycle:  \([0-9]*\)$/\1/') #'
[ -r /dev/shm/mpv-screensize ] && read lx ly < /dev/shm/mpv-screensize || { IFS=" x+" read la lb lc lx ly lz <<<$(xrandr |grep -m1 primary) ; echo $lx $ly > /dev/shm/mpv-screensize; }
[ -r /dev/shm/xheads ] || xrandr |grep -c \* > /dev/shm/xheads

trap "rm -f $spypid;xset s ${xsstimeout} ${xsstimeout} dpms ${xsstimeout} ${xsstimeout} ${xsstimeout}" HUP INT TERM
xset s 0 0 dpms 0 0 0

#stdbuf -oL
xprop -spy -root _NET_ACTIVE_WINDOW | while read -r line;do
    id=${line##* }
#        echo "# $id is active"
    ( xprop -spy -id $id WM_CLASS _NET_WM_STATE & echo $! >&3 ) 3>$spypid |
        while read a; do
#           echo "line: $a" 1>&2
#           echo "pid: $(<$spypid)" 1>&2
	    case "$a" in
		*_NET_WM_STATE_FOCUSED*_NET_WM_STATE_FULLSCREEN*)
		    echo "# id $id FULLSCREEN $wmclass"
		;;
		*_NET_WM_STATE_FOCUSED*)
		    echo "# id $id _restored $wmclass"
		;;
		WM_CLASS*)
		    IFS=\ \" read a b wmclass2 d wmclass f <<<$a
#		    echo van_wmclass: $wmclass 1>&2
		;;
		*)
		    kill -13 $(<$spypid)
#		    pkill -f -13 "xprop -spy -id $id WM_CLASS _NET_WM_STATE"
#		    exit
		;;
	    esac
        done
done|while read a b wid status class; do
    [ "$status" = "$oldstatus" ] && continue
    [ -e /dev/shm/icereload ] && continue
#    echo wmclass: $wmclass
#    IFS=\ \" read a b class2 d class f <<<$(xprop -id $wid WM_CLASS 2>/dev/null)
    [ "$class" = "taskbar" ] && continue
    read outputs < /dev/shm/xheads
    mytime "wid=$wid $class $status $outputs"
    case $status in
	FULLSCREEN)
	    unset cgroups
	    if [ "$outputs" = "1" ]; then
		if [ ! "$class" = "urxvt" ]; then
	    	    [[ "$class" != @(chromium|navigator|palemoon) ]] && cgroups+=(browser)
	    	    [ ! "$class" = "projectm-pulseaudio" ] && cgroups+=(bg)
		fi
	    else [ "$class" = "mpv" ] && pidof -q projectM-pulseaudio \
		    && [ $(icesh -w $wid getGeometry|cut -d+ -f2) -ge $lx ] \
		    && [ $(icesh -c projectM-pulseaudio getGeometry|cut -d+ -f2) -ge $lx ] \
		    && cgroups+=(bg)
	    fi
	    [ ${#cgroups[@]} -ne 0 ] && dunstify DUNST_COMMAND_PAUSE
	    for c in ${cgroups[@]};
	        do echo FROZEN > /sys/fs/cgroup/freezer/$c/freezer.state
	    done
#	    xautolock -disable 2>/dev/null
#	    icesh -window $wid setLayer 4
#	    case $class in
#		mpv|projectm-pulseaudio) xset s off -dpms s noblank ;;
#	    esac
	;;
	_restored)
	    echo THAWED > /sys/fs/cgroup/freezer/browser/freezer.state
            echo THAWED > /sys/fs/cgroup/freezer/bg/freezer.state
#	    [ $(xprintidle) -gt 600000 ] && xdotool mousemove_relative 1 1 mousemove_relative -- -1 -1
#	    [ -e /dev/shm/buckle.run ] && keysound.sh restart &>/dev/null &
	    dunstify DUNST_COMMAND_RESUME
#	    xset $xsetparam s blank +dpms
	    [ $(xprintidle) -gt ${xsstimeout}000 ] \
		&& echo "xautolock now, because of $(xprintidle) idle millisecs." \
		&& xautolock -locknow
	;;
    esac
    oldstatus="$status"
done
# | while read b;do echo b: $b;done
