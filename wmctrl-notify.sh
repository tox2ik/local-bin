#!/bin/bash

#####
#####
export DISPLAY=:0
#####
#####

if ! [[ -f /usr/bin/notify-send ]] && type apt &>/dev/null; then
	sudo apt-get install -y libnotify-bin
fi
WMCTRLD=$(wmctrl -d)
#DESKTOPS=(`echo -e "$WMCTRLD" | sed -n '/^[0-9]/ {  s/ \+.*// ; p; }' | tr $'\n' ' '`)
CURRENT=$(echo -e "$WMCTRLD" | sed -n '/[0-9]\+ \+\*/ { s/ \+.*// ;p }')
/usr/bin/notify-send -t 84 $((CURRENT+1))
