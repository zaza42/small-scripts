#!/bin/sh
# Get the coordinates of the active window's
#    top-left corner, and the window's size.
# This can be saved & loaded

getpos(){
    wmctrl -l -G > /dev/shm/winposs
}
setpos(){
	while read -r id g x y w h host app;do
#	    echo $app
	    read ta tb a b c d <<<$(xprop -id $id _NET_FRAME_EXTENTS|tr -d ,)
	    wmctrl -i -r $id -e "$g,$((x-$d)),$((y-$c)),$((w+$d+$b)),$((h+$c+$a))"
	done < /dev/shm/winposs
}

case $1 in
    get) echo getting window positions
	getpos
    ;;
    set) echo setting window positions
	setpos
    ;;
    run) getpos
	shift
	${@}
	setpos
    ;;
    *) echo "Usage: ${0##*/} [get|set|run <command>]"
    ;;
esac
