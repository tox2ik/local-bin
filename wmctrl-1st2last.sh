#!/bin/bash

if [ ! -x "`which wmctrl 2>/dev/null`" ];
then
	echo plx install wmctrl
	exit 1;
fi

if `wmctrl -d|grep -q '^0.*\*'`;
then 
	# gives 0 when on first
	echo go to last
	wmctrl -s `wmctrl -d|tail -n1|cut -c 1` ; 
else 
	# gives 1 when on last
	echo go to first
	wmctrl -s0;
fi 
