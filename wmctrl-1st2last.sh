#!/bin/dash


LAST=$2

if [ $# -lt 2 ]; 
then
	LAST=`wmctrl -d | sed -n '${ s/\([0-9]\+\).*/\1/ ;p }'`
fi

wmctrl -d | awk -v first=${1:-0} -v last=${LAST:-1} '

#{ d=$1 }

$2 ~ /\*/ { active=$1 }

END { 
	if (active != first) {	goto=first } 
	else { 					goto=last }

	system("wmctrl -s " goto) 
}'
