#!/bin/bash

#####
export DISPLAY=`x-display-1`
#####

n=${1:-0}
: $(( n-- ))
test $n -lt 0 && n=0
wmctrl -s $n


wmctrl-wait.sh $n
wmctrl-notify.sh
