function im(kB, p) {
	if (p > 0)
		return sprintf("%.1f", kB/1024)
	else
		return int(kB/1024)
}

BEGIN {
min_w=max_w=min_r=max_r=-1
data=30000
	if (verb >= 2) {
		print "kB\t",
			  "reclen\t",
			  "write\t",
			  "re-write\t",
			  "read\t",
			  "re-read\t",
			  "random_r\t",
			  "random_w\t"
	}
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

	if (verb >= 2) {
		print test "\t",
			  rec "\t",
			  r0 "\t",
			  rr "\t",
			  w0 "\t",
			  rw "\t",
			  rar "\t",
			  raw
	}
	score_r += $3 + $4 + $7
	score_w += $5 + $6 + $8
	score += score_r + score_w

	score_rc += 3
	score_wc += 3

	if (min_r == -1) { min_r = $3 }
	if (min_r  > $3) { min_r = $3 }
	if (min_r  > $4) { min_r = $4 }
	if (min_r  > $7) { min_r = $7 }

	if (min_w == -1) { min_w = $3 }
	if (min_w  > $5) { min_w = $5 }
	if (min_w  > $6) { min_w = $6 }
	if (min_w  > $8) { min_w = $8 }

	if (max_r == -1) { max_r = $3 }
	if (max_r  < $3) { max_r = $3 }
	if (max_r  < $4) { max_r = $4 }
	if (max_r  < $7) { max_r = $7 }

	if (max_w == -1) { max_w = $3 }
	if (max_w  < $5) { max_w = $5 }
	if (max_w  < $6) { max_w = $6 }
	if (max_w  < $8) { max_w = $8 }






}

END {
#print "\t\t\t\t\t\t\t\t" cmd

	  if (verb >= 1) {
	  print "",
			   " read avg " im(score_r/score_rc) "\tmin "  im(min_r,0) "\tmax " im(max_r, 0) "\n",
			   "write avg " im(score_w/score_wc) "\tmin " im(min_w,0) "\tmax " im(max_w, 0) "\n";
	  }
	  print "",
			"score " im(score  /(score_rc+score_wc)) "\n"

}

