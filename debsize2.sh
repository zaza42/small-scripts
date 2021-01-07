#!/bin/lksh
#sum package sizes which are on /

for file in /var/lib/dpkg/info/*.list; do
    echo -n . 1>&2
    package=${file##*/}
    package=${package%.list}
    sumsize=$(cat $file|xargs stat -c "%m %i %s" 2>/dev/null| sort -k2 -n -u|
	grep -oP "^/ [0-9]* \K.*"|paste -sd+)
    sumsize=$(($sumsize))
    echo $sumsize $package
done | column -t | sort -n |
    numfmt --to=iec-i --suffix=B --padding 7|
    sed -e 's/\([0-9]\)\([A-Z]\)/\1 \2/'
