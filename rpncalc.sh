#!/usr/bin/env bash

BC=`which bc`
scale=${SCALE:-2}

if [ $# -lt 3 ] || [ $(( $# %2 )) -eq 0 ]
then
	echo "Usage: $0 int int operator [int operator ...]"
	echo "       x same as * (multiply)"
	echo "       set \$SCALE to a desired precision (other than two)"
	exit 1
fi

if [ -x $BC ]
then
	ANS=`echo "scale=$scale;${1}${3//x/*}$2"| bc`

else
	echo install bc to use decimal expressions: http://www.gnu.org/software/bc/bc.html
	ANS=$(( $1 ${3//x/*} $2 ))
fi

shift 3

while [ $# -gt 0 ]
do
	if [ -x $BC ]
	then
	ANS=`echo "scale=$scale;${ANS}${2//x/*}$1" |bc`
	else
	ANS=$(( ANS ${2//x/*} $1 ))
	fi
	shift 2
done
if  [[ ${ANS} =~ ^\. ]]
then
	#echo leading dot
	echo -n 0
	echo ${ANS}
else
	echo ${ANS}
fi
