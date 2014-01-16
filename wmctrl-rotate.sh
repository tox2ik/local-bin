#!/bin/bash

# $ wmctrl -d 

# 0  - DG: 1680x2250  VP: N/A  WA: 0,0 1680x2250  firefox
# 1  * DG: 1680x2250  VP: 0,0  WA: 0,0 1680x2250  terms
# 2  - DG: 1680x2250  VP: N/A  WA: 0,0 1680x2250  misc
# 3  - DG: 1680x2250  VP: N/A  WA: 0,0 1680x2250  gui

# $ wmctrl -d | sed -n '/[0-9]\+ \+\*/ { s/ \+.*// ;p}'
# 1

WMCTRLD=$(wmctrl -d)

DESKTOPS=(`echo -e "$WMCTRLD" | sed -n '
	/^[0-9]/ { 
		s/ \+.*// ;
		p
	}'| tr $'\n' ' '`)

LASTINDEX=$(( ${#DESKTOPS[@]} -1  )) 
CURRENT=$( echo -e "$WMCTRLD" | sed -n '
	/[0-9]\+ \+\*/ { 
		s/ \+.*// ;p
	}')

NEXT=$(( CURRENT+1))
PREV=$(( CURRENT-1))

echo CURRENT $CURRENT

# wrap to the last / first destop from the first / last
[ $PREV -eq -1 ] && PREV=$LASTINDEX
[ $NEXT -gt $LASTINDEX ] && NEXT=0

[ "$1" == "next" ] && wmctrl -s $NEXT
[ "$1" == "prev" ] && wmctrl -s $PREV
[ "$1" == "" ] && echo -e "$0: rotates the desktop\nusage: $0 [next|prev] "
