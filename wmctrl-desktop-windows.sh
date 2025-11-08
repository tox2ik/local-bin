#!/usr/bin/env bash

# Find window IDs on a given or current desktop, 
# optionally filtered by title pattern.

desktop=$(wmctrl -d | awk '$2~/\*/{print $1}')
if [[ $1 =~ ^[0-9]$ ]]; then
	desktop=$1; shift
fi
wmctrl -l  | awk \
    -v desktop=$desktop \
    -v pattern=${1:-} '

$2 == desktop && $(NF) ~ pattern { print $1 }'
