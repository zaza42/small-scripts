tz=$(date "+%:::z")
mytime() {
    nowunix=${EPOCHREALTIME%.*}
    typeset -iZ2 sec=$(( (nowunix) % 60))
    typeset -iZ2 minute=$(( (nowunix-$sec) % 3600 / 60 ))
    typeset -iZ2 hour=$(( (nowunix-60*minute-$sec) % 86400 / 3600))
    eval hour=$(($hour $tz))
    ((hour>23)) && hour=$((hour-24))
    echo $hour:$minute:$sec "${@}"
}
