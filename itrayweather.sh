#!/bin/lksh

#delay=3
weatherfile=$HOME/.wmWeatherReports/LHBP.TXT
#weatherfile=/tmp/test.txt
while :; do
    unset icon
    while read -r line; do
	if [ "${line:0:7}" = "Weather" ]; then
	    case "${line#*:}" in
                *light\ rain*) icon=weather-showers-scattered ;;
                *rain*) 	icon=weather-showers ;;
                *thunder*) 	icon=weather-storm ;;
                *snow*) 	icon=weather-snow ;;
                *fog*) 		icon=weather-fog ;;
	    esac
	    break
	fi
    done < "$weatherfile"

    if [ -n "$icon" ]; then
	echo visible:true
	sleep 0.2
	echo icon:$icon
	sleep 0.2
	echo tooltip:"$line"
    else
	echo visible:false
    fi
#    sleep $delay
    inotifywait -e modify "$weatherfile"
done | yad --notification --listen \
    --command "xdg-open https://www.idokep.hu/idokep/budapest"
