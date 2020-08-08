#!/bin/bash
LAST=$2
if [ $# -lt 2 ]; 
then
	LAST=`wmctrl -d | sed -n '${ s/\([0-9]\+\).*/\1/ ;p }'`
fi

function swap() {
	wmctrl -d | awk -v first=${1:-0} -v last=${LAST:-1} '
		$2 ~ /\*/ { active=$1 }
		END { 
			if (active != first) {	goto=first } 
			else { 					goto=last }
			system("wmctrl -s " goto) 
		}'
}

swap $1

# screens=($(
# 	for d  in {0..3}; do
# 		for s in {0..3}; do
# 			ds=:$d.$s
# 			DISPLAY=$ds xrandr &>/dev/null && echo $ds
# 		done
# 	done
# 	))
# 
# for i in ${screens[@]}; do
# 	echo DISPLAY=$i swap $1
# 	DISPLAY=$i swap $1
# done


sleep 0.09 && wmctrl-notify.sh
