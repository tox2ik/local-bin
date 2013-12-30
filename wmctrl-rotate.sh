#!/bin/bash

# $ wmctrl -d 

# 0  - DG: 1680x2250  VP: N/A  WA: 0,0 1680x2250  firefox
# 1  * DG: 1680x2250  VP: 0,0  WA: 0,0 1680x2250  terms
# 2  - DG: 1680x2250  VP: N/A  WA: 0,0 1680x2250  misc
# 3  - DG: 1680x2250  VP: N/A  WA: 0,0 1680x2250  gui

# $ wmctrl -d | awk '{printf "%s%s\n", $2,$1}' 
# -0
# *1
# -2
# -3

# $ wmctrl -d | awk '{printf "%s%s\n", $2,$1}' |sort -n| cut -c 2 |tr '\n ' ' '
# 3 2 0 1 


# put all desktops in an array
desktops=(`wmctrl -d | awk '{printf "%s%s\n", $2,$1}' |sort -n| cut -c 2 |tr '\n ' ' '`)

# the active desktop will be last because of the |sort -n 
# beware, only tested on gentoo 
# sys-apps/coreutils-8.5
# sys-apps/gawk-3.1.6
# x11-misc/wmctrl-1.07-r1

# number of elements - 1 = last index of array = last desktop
LASTINDEX=$((${#desktops[@]}-1)) 

CURRENT=${desktops[$LASTINDEX]}
NEXT=$(( CURRENT+1))
PREV=$(( CURRENT-1))

# wrap to the last destop from the first
# wrap to the first desktop from the last
[ $PREV -eq -1 ] && PREV=$LASTINDEX
[ $NEXT -gt $LASTINDEX ] && NEXT=0

[ "$1" == "next" ] && wmctrl -s $NEXT
[ "$1" == "prev" ] && wmctrl -s $PREV
[ "$1" == "" ] && echo -e "$0: rotates the desktop\nusage: $0 [next|prev] "

