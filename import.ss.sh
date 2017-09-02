#!/bin/sh
IMPORT=/usr/bin/import
FORMAT=png

LASTFILE=~/.last/ss
# its up to you to make this folder writable
BASEDIR=/home/jaroslav/tmp/ss 
IMGAPP=/usr/bin/pqiv
GIMP=/usr/bin/gimp

if [ ! -d "`dirname $LASTFILE`"  ]; then
	mkdir -p "`dirname $LASTFILE`"
fi


if [ -x $IMPORT ];then


	case "$1" in

	 "png") FORMAT=png   shift 1 ;;
	 "jpg") FORMAT=jpg   shift 1 ;;
	 "bmp") FORMAT=bmp   shift 1 ;;
	"tiff") FORMAT=tiff  shift 1 ;;

	esac


#echo ss $SSFILE
#echo la $LASTFILE `cat $LASTFILE`



if [ "$1" = "-c" ] ;then 
	SSFILE="$BASEDIR/ss-win.$RANDOM.$FORMAT"
	$IMPORT  $SSFILE
	echo $SSFILE > $LASTFILE 
	

elif [ "$1" = "-e" ] ;then
	$EDITOR $0

elif [ "$1" = "-s" ] ;then
	$IMGAPP `cat $LASTFILE`

elif [ "$1" = "-g" ] ;then
	$GIMP `cat $LASTFILE`

elif [ "$1" = "-l" ] ;then
	find $BASEDIR -type f -printf "%A@ %p %kk\n"  | sort -n | sed 's/[^ ]* //'


elif [ "$1" = "-h" ] ;then
	echo usage:
	echo `basename $0` [option]
	echo options:
	echo "    -e change some variables with \$EDITOR"
	echo "    -s show last screen shot"
	echo "    -g show last screen shot in gimp"
	echo "    -c take a sceen shot of a window"
	echo "    -l list screen shots"
	echo "    take a sceen shot of a the whole screen"
	echo 
	echo internal variables:
	echo "      new files stored in   BASEDIR  \"$BASEDIR\""
	echo "    last screen shot path  LASTFILE  \"$LASTFILE\"" 
	echo "       screen shot viewer    IMGAPP  \"$IMGAPP\""  
	echo "       the default format    FORMAT  \"$FORMAT\""


	
else
	SSFILE="$BASEDIR/ss-root.$RANDOM.$FORMAT"
	$IMPORT -window root $SSFILE
	echo $SSFILE > $LASTFILE 
fi




else
echo please install imagemagick and set IMPORT to \`which import\`
fi

unset IMPORT FORMAT LASTFILE BASEDIR IMGAPP SSFILE
