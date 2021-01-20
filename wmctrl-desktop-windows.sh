#!/bin/sh
desktop=$(wmctrl -d | awk '$2~/\*/{print $1}')
if [[ $1 =~ ^[0-9]$ ]];
then
	desktop=$1
	shift
fi
wmctrl -l  | awk -v cur=$desktop -v pattern=${1:-} '$2 == cur && $(NF) ~ pattern { print $1 }'

