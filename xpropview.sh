#!/bin/lksh
# suspend dunst when window is fullscreen

source ~/scripts/mytime.inc

typeset -l class
typeset -l lastclass
typeset -i curdesk
#typeset -i auddesk curdesk
#auddesk=1
typeset -i isfull
typeset -i oldfull=0
typeset -i oldlang=0
typeset -x audonscreen
typeset -l xsetparam=$(xset q|sed '/timeout/!d; s/^.*timeout:  \([0-9]*\).*cycle:  \([0-9]*\)$/s \1 \2s00/') #'
typeset -l displayx=$(xrandr|grep -oP -m1 "   \K.*(?=x.*\*\+$)") #"

function audplugins () {
    if ! [ "$1" = "$audonscreen" ]; then
	for plugin in blur_scope cairo-spectrum albumart; do
		timeout 1 audtool plugin-enable $plugin $1 &
        done
        audonscreen=$1
	wait
    fi
}

echo "xprop started"
stdbuf -oL xprop -spy -root _NET_ACTIVE_WINDOW _NET_CURRENT_DESKTOP | while read -r line
    do
#	    if [ "$oldline" = "$line" ]; then continue; fi
#	    oldline=$line
	    id=${line##* }
	    if [ "${id:0:2}" = "0x" ]; then
		class=$(xprop -id $id WM_CLASS)
		class=${class#*, }
		class=${class//[\" ]/}
		palerun=0
		projectmrun=0
		case $class in
#		    firefox|seamonkey|light|palemoon) killall -18 $class
		    chromium|palemoon|basilisk|firefox)
#			    killall -18 palemoon-bin palemoon plugin-container basilisk-bin basilisk firefox-bin firefox chromium 2>/dev/null
			    palerun=1
#			    audplugins off
			    wname=$(xprop -id $id _NET_WM_NAME)
                                case $wname in
                            	    *stackexchange*|*codegold*|*stackoverflow*|*superuser*|*serverfault*|*github* ) lang="0"
                            	    ;;
                            	    *) lang="1"
                            	    ;;
				esac
		    ;;
#		    audacious) 
#			       if [ "$audonscreen" = "off" ]; then
##				    winact=$(xdotool getactivewindow)
#				    killall -18 audacious
#				    audplugins on
##				    xdotool windowactivate $winact
##				    xdotool windowfocus $winact
#				    auddesk=$curdesk
#				fi
#		    ;;
		    urxvt|rxvt|smplayer|mpv|mplayer|gnome-twitch ) lang="0"
		    ;;
		    vncviewer|hexchat ) lang="1"
		    ;;
		    projectm* ) xseticon -id "$id" /home/DC-1/.local/share/icons/prjm16-transparent.png
				killall -CONT projectM-pulseaudio
			        projectmrun=1
		    ;;
		    *) lang="2"
		    ;;
		esac

#		read l1 l2 < /proc/loadavg
#		[ ${l1/.} -gt 800 ] && kill -9 $(ps -eho pid --sort -rss )

		FS=$(xprop -id $id _NET_WM_STATE)
		case "$FS" in 
			*FULLSCREEN*) isfull=1 ;;
			*) isfull=0 ;;
		esac
#		echo FS: $FS isfull=$isfull oldfull=$oldfull
		read x y <<<$(xdotool getwindowgeometry $id|grep -oP "Position: \K[0-9]*")
		if [ $x -ge $displayx ]; then
		    echo -n "\n"$(mytime "2nd_head")
		    icesh -window $id setState AllWorkspaces 1
		    icesh -window $id setTrayOption 2
		fi
	    else
		curdesk=$id
#		if [ "$curdesk" = "$auddesk" ]; then audplugins on;fi
	    fi
	    if [ $isfull -ne $oldfull ] ; then
	      echo -n "\n"$(mytime isfull: $isfull)
#	      echo oldfull:$oldfull
	      oldfull=$isfull
	      case $FS in
		*FULLSCREEN*)   #case $class in xv|mpv ) sismpv.sh f ;; esac
				dunstify DUNST_COMMAND_PAUSE
#				if $(timeout 1 audtool --playback-playing) ; then
#				    audplugins off
#				else
#				    killall -STOP audacious
#				fi
				killall -STOP xautolock 2>/dev/null
				((projectmrun)) || killall -STOP projectM-pulseaudio 2>/dev/null
#				((palerun)) || killall -STOP palemoon-bin palemoon plugin-container basilisk-bin basilisk firefox firefox-bin 2>/dev/null
				xset s off -dpms
				xset s noblank
				
		;;
		*)	dunstify DUNST_COMMAND_RESUME
#			killall -18 xautolock xpenguins xsnow gkrellm audacious xtigervncviewer 2>/dev/null
			killall -18 xautolock projectM-pulseaudio 2>/dev/null
			xset $xsetparam
			xset s blank
#			if [ "$curdesk" = "$auddesk" ]; then audplugins on;fi
		;;
	      esac
	    fi
#	    echo "lastclass=$lastclass class=$class"
#            && ! [ "$oldlang" = "$lang" ]; then
#            if ! [ "$lastclass" = "$class" ]; then
#	    if [ $lang -eq 2 ]; then
#		mytime "lang: none"
#	    else
	    if [ $lang -ne 2 ] && [ $(xkblayout-state print "%c ") -ne $lang ]; then
                case $lang in
                    0) xkblayout-state set $lang 2>/dev/null; echo -n "\n"$(mytime "lang: us")
#			xkblayout-state set $lang 2>/dev/null; mytime "lang: us"
		    ;;
                    1) xkblayout-state set $lang 2>/dev/null; echo -n "\n"$(mytime "lang: hu")
		    ;;
                esac
		oldlang=$lang
#		fi
            fi
            lastline=$line
            lastclass=$class
    done
