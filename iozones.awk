function im(kB, p) {
	if (p > 0)
		return sprintf("%.1f", kB/1024)
	else
		return int(kB/1024)
}

BEGIN {
min_w=max_w=min_r=max_r=-1
data=999999
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
NR >= data && NF==0 { data=999999 }
NR >= data {
	test=$1
	rec=$2
	r0=int($3) # read
	rr=int($4) # re-read
	w0=int($5) # write
	rw=int($6) # re-write
	rar=int($7) # random read
	raw=int($8) # random write

	if (verb >= 2) {
		print test "\t",
			  rec "\t",
			  im(r0) "\t",
			  im(rr) "\t",
			  im(w0) "\t",
			  im(rw) "\t",
			  im(rar) "\t",
			  im(raw)
	}
	score_r += r0 + rr + rar
	score_w += w0 + fw + raw
	score += score_r + score_w

	score_rc += 3
	score_wc += 3

	if (min_r == -1) { min_r = r0 }
	if (min_r  > r0) { min_r = r0 }
	if (min_r  > rr) { min_r = rr }
	if (min_r  > rar) { min_r = rar }

	#if (min_w == -1) { min_w = w0 }
	#if (min_w  > w0) { min_w = w0 }
	#if (min_w  > rw) { min_w = rw }
	#if (min_w  > raw) { min_w = raw }

	if (max_r == -1) { max_r = r0 }
	if (max_r  < r0) { max_r = r0 }
	if (max_r  < rr) { max_r = rr }
	if (max_r  < rar) { max_r = rar }

	#if (max_w == -1) { max_w = w0 }
	#if (max_w  < w0) { max_w = w0 }
	#if (max_w  < rw) { max_w = rw }
	#if (max_w  < raw) { max_w = raw }

}

END {
#print "\t\t\t\t\t\t\t\t" cmd
#


	  if (verb >= 1) {
	  print "",
			   " read avg " im(score_r/score_rc) "\tmin "  im(min_r,0) "\tmax " im(max_r, 0) "\n",
			   "write avg " im(score_w/score_wc) "\tmin " im(min_w,0) "\tmax " im(max_w, 0) "\n";
	  }
	  print "",
			im(score  /(score_rc+score_wc)) "\n"

}

