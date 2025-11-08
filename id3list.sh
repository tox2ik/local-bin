#!/usr/bin/env bash

if [ "$1" == "" ]; then
		echo "give me a directory to list" >&2
		echo "using `pwd`" >&2
		echo >&2
		DIR="`pwd`"
		exec $0 $DIR
		exit 0;
else
		DIR=$1;
fi


FILES=0;
find "$DIR" -iname '*.mp3' -type f |  while read -r LINE;
do
		FILEINFO=`id3info "$LINE" |grep -E '^==='` ;

		artist=`echo -e "$FILEINFO" | grep -E '=== TPE1'`
		album=` echo -e "$FILEINFO" | grep -E '=== (TALB|TOAL)'`
		year=`  echo -e "$FILEINFO" | grep -E '=== (TYER|TDAT)'`
		track=` echo -e "$FILEINFO" | grep -E '=== TRCK'`
		title=` echo -e "$FILEINFO" | grep -E '=== TIT2'`
		artist=${artist/#*): /}
		album=${album/#*): /}
		year=${year/#*): /}
		track=${track/#*): /}
		title=${artist/#*): /}

		echo -n  $artist
		echo -en "\t\t$album"
		echo -en "\t\t${year:-????}"
		echo -en "\t$track"
		echo -e  "\t$title"

		#echo "
		#ARTISTS['${FILES}']=$artist
		#ALBUMS['${FILES}']=$album
		#YEARS['${FILES}']=$year
		#TRACKS['${FILES}']=$track
		#TITLES['${FILES}']=$title
		#"
		FILES=$((FILES+ 1))
done
