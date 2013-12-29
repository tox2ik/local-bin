#!/bin/bash

if [ "$1" == "" ]; then
	echo "give me a directory to list"
	echo "using `pwd`"
	echo 
	DIR="`pwd`"
	$0 $DIR
	exit 0;
	
else

	DIR=$1;
fi




FILES=0;
ls -1 ${DIR}/*mp3 |  while read LINE; 
do 

	FILEINFO=`id3info "$LINE" |grep -E '^==='` ;

	

	artist=`echo -e $FILEINFO |sed 's/===\ /\n/g' | grep -E 'TPE1' |sed 's/.*:\ //'`
	 album=`echo -e $FILEINFO |sed 's/===\ /\n/g' | grep -E 'TALB|TOAL' |sed 's/.*:\ //'`
	  year=`echo -e $FILEINFO |sed 's/===\ /\n/g' | grep -E 'TYER|TDAT' |sed 's/.*:\ //'`
	 track=`echo -e $FILEINFO |sed 's/===\ /\n/g' | grep -E 'TRCK' |sed 's/.*:\ //'`
	 title=`echo -e $FILEINFO |sed 's/===\ /\n/g' | grep -E 'TIT2' |sed 's/.*:\ //'`


	 #echo a: $artist t: $title



	 echo -n  $artist
	 echo -en "\t\t$album"
	 echo -en "\t\t$year"
	 echo -en "\t$track"
	 echo -e  "\t$title"

	 ARTISTS[${FILES}]=$artist
	  ALBUMS[${FILES}]=$album
	   YEARS[${FILES}]=$year
	  TRACKS[${FILES}]=$track
	  TITLES[${FILES}]=$title



	FILES=$((FILES+ 1))
done

## the code below does not work at all because the arrays above are different from the ones below
## the reason is they are created in a subshell we know nothing about.

## i need to find a way to handle files in for or while loops without external programs. 
## 

elements=${#ARTISTS[@]}        


for i in `seq 0 $FILES` ;do

	#printf "%s\t\t %s\n" ${ARTISTS[i]} ${TITLES[i]}
	echo -e " ${ARTISTS[i]} \t\t ${ALBUMS[i]} \t\t ${YEARS[i]} \t\t ${TRACKS[i]} \t\t ${TITLES[i]}"
done
