#!/bin/sh
exiftool -duration "$@" |
awk '
s = 0
/^={8}/ { 
	$1 = ""; 
	gsub(/^=* /,"", $0)
	fname = $0
}

/^Duration/ {
	gsub(/\ \(approx\)/, "", $0)
	gsub(/Duration\ /,   "", $0)
	split($0 ,colons, ":")

	if (length(colons)==4){
	
		H_ += colons[2]
		M_ += colons[3]
		S_ += colons[4]
		s += colons[2]* 3600 + colons[3]* 60 + colons[4]

	} else if (length(colons)==2) {
		S_ += colons[2]
		s += colons[2]

	} else {
		printf "OUCH %s %s\n" , $0, fname

	}

	t += s

	printf "%4.1f %7.2f %5d %s\n", s/3600, s/60, s, fname
}

END {

	M += S_ / 60
	S  = S_ % 60

	M_ += M

	H = M_ / 60 
	M = M_ % 60

	H += H_

#	printf "H_ %3d  H %d \n", H_, H
#	printf "M_ %3d  M %d \n", M_, M
#	printf "S_ %3d  S %d \n", S_, S

	printf "%4.1f %7.2f %5d %d:%d:%d total of %d files\n", t/3600, t/60, t, H,M,S, NR/2
	printf "%4s %7s %5s\n", "hrs", "min", "sec"

}
'
