#!/usr/bin/env bash

input=${1:-/tmp/input-file.png}

if [ ! -f $input.orig ]; then
cp "$input" $input.orig; 
ln "$input" "/tmp/$input"
fi


for f in {0..5}; do
   for l in {0..9}; do
      for s in {0..4}; do
         outfile="/tmp/opt-png-out_${f}_${l}_${s}.png"
         echo convert "$input" \
	 -define png:compression-filter=$f \
	 -define png:compression-level=$l \
	 -define png:compression-strategy=$s "$outfile"
      done
   done
done | parallel -j8


optimal=$(du -sb /tmp/opt-png-out_* | sort -nr  | awk '{e=$2 } END{ print e }')

du -sb $optimal $input
feh $optimal $input
echo mv -f $optimal $input

