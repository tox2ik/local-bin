#!/bin/sh 

TMPF=/tmp/id3notags.sh-tmpf

if [ "$2" != "" ] ;then 



	artist=`id3info "$2" | grep -E 'TPE1' |sed 's/.*:\ *//'`
	 title=`id3info "$2" | grep -E 'TIT2' |sed 's/.*:\ *//'`

	if [ "$artist" == "" -o "$title" == "" ] ;then 


		#echo `dirname "$2"`: a: $artist t: $title \(`basename "$2"`\)

		PREV=`cat $TMPF`
		CRNT=`dirname "$2"`

		if [ "$PREV" != "$CRNT" ];then 

			echo picard \"$CRNT\" \&
			echo $CRNT > $TMPF
		fi

		exit 0;
	fi
	exit 1;
fi


if [ "$1" == "" ]; then
	echo "give me a directory to list"
	sleep 0.3
	echo "using `pwd`"
	sleep 0.3
	sleep 0.3

	DIR=`pwd`
	$0 $DIR 
	
else

	DIR=$1;
	find $DIR -iname "*mp3" -type f -exec $0 $DIR {} \;

fi




