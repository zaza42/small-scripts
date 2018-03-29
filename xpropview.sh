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
typeset -i lang=0
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
#	pkill -x -13 xxkb >/dev/null ; sleep 0.1 ; xxkb &
#	sleep 1 && icesh -c claws-mail setState Hidden add
}
function langset () {
if [ -n "$lang" ] && [ $lang -ne 2 ] && [ $(xkblayout-state print "%c ") -ne $lang ]; then
    case $lang in
        0) xkblayout-state set $lang 2>/dev/null; echo -n "\n"$(mytime "lang: us") ;;
        1) xkblayout-state set $lang 2>/dev/null; echo -n "\n"$(mytime "lang: hu") ;;
    esac
    oldlang=$lang
fi
}
function 2ndhead () {
		windesk=$(xdotool get_desktop_for_window $id 2>/dev/null)
		if [ ! "$windesk" = "-1" ]; then
		    read x y <<<$(xdotool getwindowgeometry $id 2>/dev/null|grep -oP "Position: \K[0-9]*")
		    x=${x:-0}
		    if [ -n $x ] && [ $x -ge $displayx ]; then
			echo -n "\n"$(mytime "2nd_head")
#			1.4.2-vel igy ment:
#		    icesh -window $id setState AllWorkspaces 1
#			1.4.3 ota ez a workaround
			icesh -window $id setWorkspace 0xFFFFFFFF setTrayOption 2
#			icesh -window $id setTrayOption 2
		    fi
		fi
}
function browserlangcheck () {
    case $class in
	chromium|palemoon|basilisk|firefox)
		wmname=${1##*::: }
		if [ "${wmname:0:4}" = "http" ]; then
                    case $wmname in
                	*stackexchange*|*codegold*|*stackoverflow*\
			|*superuser*|*serverfault*|*github*\
			|*debian.*|*pouet* ) lang="0"
                    ;;
                    *)  lang="1"
                    ;;
		    esac
#		    mytime "lang w: _${wmname}_"
		    langset
		fi
    esac
}
function fulldo () {
[ "$class" = "taskbar" ] && isfull=$oldfull
if [ -n "$isfull" ] && [ $isfull -ne $oldfull ]; then
#    echo -n "\n"$(mytime isfull: $isfull)
    echo -n "\n"$isfull
    echo -n "\n$(mytime full: $isfull) ${class}" >&2
    oldfull=$isfull
    case $isfull in
	1)  dunstify DUNST_COMMAND_PAUSE
#				if $(timeout 1 audtool --playback-playing) ; then
#				    audplugins off
#				else
#				    killall -STOP audacious
#				fi
	    stopapps="xautolock glava"
	    outputs="$(xrandr |grep -c \*)"
	    case "$outputs" in
		1)
		    ((projectmrun)) || stopapps+=" projectM-pulseaudio"
		    ((palerun)) || stopapps+=" chromium palemoon-bin palemoon plugin-container libpepflashplayer.so"
		;;
	    esac
#	    pkill -STOP "$stopapps"
#	    echo "killall -STOP $stopapps" >&2
	    killall -STOP $stopapps 2>/dev/null
	    xset s off -dpms
	    xset s noblank
	    icesh -window $id setLayer 4
	    2ndhead $id
	;;
	*)  dunstify DUNST_COMMAND_RESUME
	    pidof buckle >/dev/null && bucklerun=true || bucklerun=false
#	    $bucklerun && keysound.sh off
#	    xte 'keydown Control_L' 'key space' 'keyup Control_L'
#	    $bucklerun && keysound.sh on
#	    pkill -CONT "chromium|xautolock|projectM-pulseaudio|glava|palemoon|palemoon-bin|plugin-container"
	    killall -CONT chromium xautolock projectM-pulseaudio glava \
		palemoon palemoon-bin plugin-container libpepflashplayer.so \
		2>/dev/null
	    xset $xsetparam
	    xset s blank
#	    if [ "$curdesk" = "$auddesk" ]; then audplugins on;fi
	;;
    esac
fi
}

function fulle() {
    id=$1
    local focused
    class=$(xprop -id $id WM_CLASS 2>/dev/null)
    class=${class#*, }
    class=${class//[\" ]/}
#    isfull=0
    xprop -spy -id $id _NET_WM_STATE _NET_WM_NAME 2>/dev/null|
#    oldfull=0
    while read a; do
#    echo fline "$a" >&2
        case "$a" in
	*_NET_WM_STATE_FOCUSED*) true
	    focused=1
	    case "$a" in
		*_NET_WM_STATE_FULLSCREEN*) isfull=1
		;;
		*) isfull=0
		;;
	    esac
	;;
	*_NET_WM_NAME*)
#		case $(xprop -id $id _NET_WM_STATE) in
#		*_NET_WM_STATE_FOCUSED*)
		[ "$focused" = "1" ] && browserlangcheck "$a"
#		esac
	;;
	*) #isfull=0
	    #fulldo
	   focused=0
	    pkill -f -13 "xprop -spy -id $id _NET_WM_STATE"
#		    exit
#	    break
	;;
        esac
	fulldo
    done;
#    echo $isfull;
#isfull=0;
fulldo;
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
			    wmname="$(xprop -id $id _NET_WM_NAME)"
			    [ -n "$wmname" ] && browserlangcheck "$wmname"
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
		2ndhead $id
	;;
	_NET_CLIENT_LIST_STACKING*)
		id="${line##* }"
		[ "${id:0:2}" = "0x" ] || continue
		FS=$(xprop -id $id _NET_WM_STATE 2>/dev/null)
#		echo "fse: $isfull - $FS"
		case "$FS" in
			*FULLSCREEN*) isfull=1 ;;
			*) isfull=0 ;;
		esac
		fulldo >/dev/null
	;;
    esac
#	    mytime lang2 lang=$lang
	    langset
#	    fulle $id
	    fulldo
	    str=$(fulle $id)
#	    fulle $id
#	    i=$((${#str}-1))
	    oldfull=${str:$((${#str}-1)):1}
#	    oldfull=0
	    fulldo
            lastline=$line
            lastclass=$class
done
