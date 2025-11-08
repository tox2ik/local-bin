#!/usr/bin/env bash

#####
#####
export DISPLAY=:0
hash x-display-1 && export DISPLAY=`x-display-1`
#####
#####

if [ $# -lt 2 ];
then
	LAST=`wmctrl -d | sed -n '${ s/\([0-9]\+\).*/\1/ ;p }'`
fi
function swap() {
	local f=${1:-0} l=${2:-$LAST}
	wmctrl -d | awk -v first=$f -v last=$l '
		$2 ~ /\*/ { active=$1 }
		END {
			if (active != first) {	goto=first }
			else { 					goto=last }
			system("wmctrl -s " goto)
			print goto
		}'
}

FIRST=$1
LAST=$2
going_to=$(swap $FIRST $LAST)

wmctrl-wait.sh $going_to
wmctrl-notify.sh


# vim: fdm=marker
