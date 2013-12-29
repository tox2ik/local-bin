#!/bin/bash

abort=0

if [ ! -f "$1" ];
then
	echo first arg is file to extract. quitting.
	exit 1
else 
	IFS=$'\n'
	files=(`rar vb $1`)

	if [ ${#files[@]} -eq 0 ];
	then
		echo "$1 is not a rar archive (or contains no files)"
	fi
fi

if [ -d "$2" ];
then
	dir=`echo $2|sed -e 's,\([^/]\)$,\1/,'`

	for (( i=0; i< ${#files[@]}; i++ ));
	do
		files[i]=${dir}${files[i]}
	done
fi


echo "Files in archive:" 
for (( i=0; i< ${#files[@]}; i++ ));
	do
		if [ -e "${files[i]}" ];
		then
			abort=1
			collision=1
		else
			collision=0
		fi

		if [ $collision -eq 1 ];
		then 
			echo -n " X  "
		else 
			echo -n "    "
		fi

		echo  ${files[i]} 

done

if [ "$abort" -ne 1 ];
then
	if [ -z "$2" ];
	then
		rar x "$1"  | sed -e '/\.\.\./d' -e '/^$/d' 
	else
		rar x "$1" "$2" | sed -e '/\.\.\./d' -e '/^$/d' 
	fi
else
	echo " X: exists already, aborting extraction"
	exit 2
fi
