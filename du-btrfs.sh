#!/bin/bash


if [[ $USER != root ]]; then
	echo sudo $0 "$@"
	exit
fi

awk_script=$(dirname $0)/$(basename $0 .sh).awk
btrfs_path=${1:-/}

volumes() {
	roots=$(
	btrfs subvolume list --sort=rootid $btrfs_path |
		awk '!_[$(NF-2)]++ { print $(NF-2) }' |
		tr '\n' '|' |
		sed 's/|$//'
	)
	btrfs subvolume list --sort=rootid "$btrfs_path" |
			awk -v rex="^($roots)$" '$2 !~ rex { print $(NF) }'
}

{
	printf "%9s %9s %9s %s\n" Total Exclusive SetShared Path
	for i in `volumes`; do
		if [[ -e $btrfs_path/$i ]]; then
			echo bash -c "'awk -v path=$i -f $awk_script <(btrfs filesystem du -s --raw $btrfs_path/$i)'"
		fi
	done | parallel -j16
}

