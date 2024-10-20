#!/bin/bash

#####
export DISPLAY=`x-display-1`
#####

if ! [[ -f /usr/bin/notify-send ]] && type apt &>/dev/null; then
	sudo apt-get install -y libnotify-bin
fi
WMCTRLD=$(wmctrl -d)
CURRENT=$(echo -e "$WMCTRLD" | sed -n '/[0-9]\+ \+\*/ { s/ \+.*// ;p }')
#/usr/bin/notify-send -c wm-info -t 84 $((CURRENT+1))

twmnc -c $((CURRENT+1)) -p 9007 -d 84
