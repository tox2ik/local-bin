#!/bin/bash
going_to=${1:-0}
function active { wmctrl -d | awk '$2 ~ /\*/ { print $1 }'; }
i=1;
while [[ $i -le 5 ]] && [[ $going_to -ne `active` ]]; do
	echo 1>&2 $i going to $going_to, active `active` 
	let i=i+1
	sleep 0.05
done
