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
function xxkbrestart () {
		echo -n "\n"$(mytime "xxkb restart")
		pkill -x -13 xxkb >/dev/null ; xxkb &
#		pkill -x -13 xxkb >/dev/null ; sleep 0.1 ; xxkb &
#		sleep 1 && icesh -c claws-mail setState Hidden add
}
function browserlangcheck () {
	    case $class in
		    chromium|palemoon|basilisk|firefox)
			wmname=${a##*::: }
			if [ "${wmname:0:4}" = "http" ]; then
                                case $wmname in
                            	    *stackexchange*|*codegold*|*stackoverflow*\
				    |*superuser*|*serverfault*|*github*\
				    |*debian.org* ) lang="0"
                            	    ;;
                            	    *) lang="1"
                            	    ;;
				esac
				langset
			fi
	    esac
}
function langset () {
	    if [ $lang -ne 2 ] && [ $(xkblayout-state print "%c ") -ne $lang ]; then
                case $lang in
                    0) xkblayout-state set $lang 2>/dev/null; echo -n "\n"$(mytime "lang: us") >&2
		    ;;
                    1) xkblayout-state set $lang 2>/dev/null; echo -n "\n"$(mytime "lang: hu") >&2
		    ;;
                esac
		oldlang=$lang
            fi
}
function fulldo () {
	if [ -n "$isfull" ] && [ $isfull -ne $oldfull ] ; then
	      echo -n "\n"$(mytime isfull: $isfull)
	      echo -n "\n"$(mytime isfull: $isfull) >&2
	      oldfull=$isfull
	      case $isfull in
		1)
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
				icesh -window $id setLayer 4
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
}

function fulle() {
    id=$1
    xprop -spy -id $id _NET_WM_STATE _NET_WM_NAME 2>/dev/null|
#    oldfull=0
    (while read a; do
#    echo fline "$a" >&2
        case "$a" in
	*_NET_WM_STATE_FOCUSED*) true
	    case "$a" in
		*_NET_WM_STATE_FULLSCREEN*) isfull=1
		;;
		*) isfull=0
		;;
	    esac
	;;
	*_NET_WM_NAME*)
		case $(xprop -id $id _NET_WM_STATE) in
		*_NET_WM_STATE_FOCUSED*)
		    browserlangcheck
		esac
	;;
	*) isfull=0
	    pkill -f -13 "xprop -spy -id $id _NET_WM_STATE"
#		    exit
	;;
        esac
	fulldo
    done; isfull=0;fulldo;)
}

echo "xprop started"
stdbuf -oL xprop -spy -root _NET_ACTIVE_WINDOW _NET_CLIENT_LIST_STACKING 2>/dev/null \
| while read -r line; do
    case $line in
#	_WIN_SUPPORTING_WM_CHECK*) xxkbrestart
#	;;
	_NET_ACTIVE_WINDOW*)
		id=${line##* }
		[ "${id:0:2}" = "0x" ] || continue
		class=$(xprop -id $id WM_CLASS 2>/dev/null)
		[ -n "$class" ] || continue
		class=${class#*, }
		class=${class//[\" ]/}
		palerun=0
		projectmrun=0
		case $class in
		    chromium|palemoon|basilisk|firefox)
#			    killall -18 palemoon-bin palemoon plugin-container basilisk-bin basilisk firefox-bin firefox chromium 2>/dev/null
			    palerun=1
#			    audplugins off
#			    wname=$(xprop -id $id _NET_WM_NAME 2>/dev/null)
#			    browserlangcheck
#                                case $wname in
#                            	    *stackexchange*|*codegold*|*stackoverflow*\
#				    |*superuser*|*serverfault*|*github*|*Issue*\
#				    |*Debian\ Bug* ) lang="0"
#                            	    ;;
#                            	    *) lang="1"
#                            	    ;;
#				esac
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
		    ffplay ) xseticon -id "$id" /home/DC-1/.icons/ffmpeg.png
		    ;;
		    *) lang="2"
		    ;;
		esac
		read x y <<<$(xdotool getwindowgeometry $id|grep -oP "Position: \K[0-9]*")
		if [ $x -ge $displayx ]; then
		    echo -n "\n"$(mytime "2nd_head")
#			1.4.2-vel igy ment:
#		    icesh -window $id setState AllWorkspaces 1
#			1.4.3 ota ez a workaround
		    icesh -window $id setWorkspace 0xFFFFFFFF
		    icesh -window $id setTrayOption 2
		fi
	;;
#	_NET_CLIENT_LIST_STACKING*)
#		id=${line##* }
#		[ "${id:0:2}" = "0x" ] || continue
#		FS=$(xprop -id $id _NET_WM_STATE)
#		case "$FS" in
#			*FULLSCREEN*) isfull=1 ;;
#			*) isfull=0 ;;
#		esac
#	    echo FS: "$FS"
#		fulldo
##	;;
    esac
#	    echo xkblang: $(xkblayout-state print "%c ") lang: $lang
#echo -n "\n langsetelott"
	    langset
	    str=$(fulle $id)
	    i=$((${#str}-1))
	    oldfull=${str:$i:1}

            lastline=$line
            lastclass=$class
    done
