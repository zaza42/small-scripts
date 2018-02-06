#!/bin/sh
PULSE_SINK=alsa_output.pci-0000_00_1b.0.analog-stereo
oldsec=$SECONDS
xinput test-xi2 --root "AlpsPS/2 ALPS DualPoint TouchPad" \
| grep --line-buffered "EVENT type 15 (RawButtonPress)"| while read line; do
    if [ $oldsec -lt $((SECONDS)) ];
	then paplay --volume 22000 -d $PULSE_SINK $HOME/scripts/data/click.aiff
    fi
    oldsec=$SECONDS
done
