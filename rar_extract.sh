#!/bin/bash

abort=0
dir=.

for i;
do
	if [[ -f $i ]]; then file=$i; fi
	if [[ -d $i ]]; then dir=$i; fi
	if [[ $i == -d ]]; then dir=1; fi
done

if [[ $dir != . ]]; then
	dir=$(dirname -- "$file")
fi

if [ ! -f "$file" ];
then
	echo first arg is file to extract. quitting.
	exit 1
else
	IFS=$'\n'
	files=(`rar vb "$file"`)

	if [ ${#files[@]} -eq 0 ];
	then
		echo "$file is not a rar archive (or contains no files)"
	fi
fi

if [ -d "$dir" ];
then
	dir=`echo "$dir" |sed -e 's,\([^/]\)$,\1/,'`

	for (( i=0; i< ${#files[@]}; i++ ));
	do
		files[i]=${dir}${files[i]}
	done
fi


#echo "Files in archive:"
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
			echo -n "target exists: "
		else
			echo -n "    "
		fi

		_out=${files[i]}
		echo ${_out##./}

done

if [ "$abort" -ne 1 ];
then
	if [[ -z "$dir" ]] || [[ $dir == . ]];
	then
		rar x "$file"  | sed -e '/\.\.\./d' -e '/^$/d'
	else
		rar x "$file" "$dir" | sed -e '/\.\.\./d' -e '/^$/d'
	fi
else
	exit 2
fi
