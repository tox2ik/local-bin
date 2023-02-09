NR > 1 {
    Total+=$1
	Exclusive+=$2
	SetShared+=$3
	Filename=$4
}
END {
	printf "%9s %9s %9s %s\n",
		int(Total/1024/1024),
		int(Exclusive/1024/1024),
		int(SetShared/1024/1024),
		path
}
