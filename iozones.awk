BEGIN {
data=30000
print "kB\t",
	  "reclen\t",
	  "write\t",
	  "re-write\t",
	  "read\t",
	  "re-read\t",
	  "random_r\t",
	  "random_w\t"
}
$1 == "Command" { cmd=$0; gsub(/^\s+/, "", cmd) }
$1 == "random" { data=NR+2 }
NR >= data && NF==0 { data=30000 }
NR >= data {
	test=$1
	rec=$2
	r0=int($3/1024)
	rr=int($4/1024)
	w0=int($5/1024)
	rw=int($6/1024)
	rar=int($7/1024)
	raw=int($8/1024)
	print test "\t",
		  rec "\t",
		  r0 "\t",
		  rr "\t",
		  w0 "\t",
		  rw "\t",
		  rar "\t",
		  raw
	score_r += $3 + $4 + $7
	score_w += $5 + $6 + $8
	score += score_r + score_w
}

END {
#print "\t\t\t\t\t\t\t\t" cmd

print "",
	  " read " int(score_r/1024) "\n",
	  "write " int(score_w/1024) "\n",
	  "score " int(score  /1024) "\n"

}
