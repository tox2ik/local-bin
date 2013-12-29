#!/usr/bin/awk -f
BEGIN { FS="-" }
{

gsub("_"," ",$1)

rest=""
for (i=2; i<=NF; i++) {
	rest=rest$i
	if (i<NF) rest=rest"-"
}

split(rest,r,".")

if		( length(r) < 1 ) { ext="" }
else if	("coremods"==r[2]) { ext="."r[3]; cm=r[2] } 
else { 
		ext="."r[2]; cm="" }

printf " %-50s %-15s %-4s\n", $1 , r[1], ext
}
