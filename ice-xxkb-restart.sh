#!/bin/lksh
source ~/scripts/mytime.inc
#restart xxkb after `icewm -r`
xprop -spy -root _WIN_SUPPORTING_WM_CHECK 2>/dev/null| while read a; do
#    echo "# $a"
    mytime "IceWM restart...restarting xxkb"
    if [ -n "$a" ]; then
	pkill -x xxkb; sleep 1; xxkb &
	(sleep 1 && icesh -c claws-mail setState Hidden add) &
	killall icewmbg
#	sleep 1
#	killall -9 icewmbg
#	sleep 1
	icewmbg &
	outputs="$(xrandr |grep -c \*)"
	case "$outputs" in
	    3) sed -e '/^vo=/s/^.*$/vo=xv/' -i ~/.config/mpv/mpv.conf
		killall glava
	    ;;
	    2) sed -e '/^vo=/s/^.*$/vo=gpu,vdpau,xv,wayland/' -i ~/.config/mpv/mpv.conf
		killall glava
	    ;;
	    1) sed -e '/^vo=/s/^.*$/vo=gpu,vdpau,xv,wayland/' -i ~/.config/mpv/mpv.conf
		pidof glava 2>/dev/null || glava &
	    ;;
	esac
    fi
done
