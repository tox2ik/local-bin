#!/bin/bash
 
read line
nick=`echo $line | sed 's/^\(.*\)---.*$/\1/'`
msg=`echo $line | sed 's/^.*---\(.*\)$/\1/'`
notify-send -i gtk-dialog-info -t 5000 "$nick" "$msg"
 
# vim:set ft=sh ts=8 sw=4 tw=0 ff=unix noet:
