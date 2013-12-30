#!/bin/dash

wmctrl -d | awk '
{ d=$1 }

$2 ~ /\*/ { D=$1 }

END { 
	if (D > 0) {
		goto=0 } 
	else {
		goto=d }
	system("wmctrl -s " goto) 
}'
