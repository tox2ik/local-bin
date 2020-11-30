#
# make_input() {
# 		find * -maxdepth 0 -type f -print0 |
# 			 xargs -0 -I% find -name '%' -print0 |
# 			 xargs -0 -n1  md5sum-part |
# 			 grep -Eve '(rar|idx|sub)$' |
# 			 sort > ~/tmp/fff
# }
#
# digest only a part of a file:
#
#     # cat ~/bin/md5sum-part
#     #!/bin/bash
#     hash=$(
#             dd if="$1" bs=1M count=1 2>/dev/null | md5sum | awk '{ print $1 }'
#     )
#     echo $hash $1
#
# verify output
#     
#     awk -f rm.awk  < ~/tmp/fff  | rev  | sort | rev | grep -v -Ee '(mkv|avi|mp4|idx|wmv|sub)$'
#     awk -f rm.awk  < ~/tmp/fff  | rev  | sort | rev | tr '\n' '\0' | xargs -0 -I@ printf "%90s\n" "@"
#
# drop stuff
#
#     awk -f rm.awk  < ~/tmp/fff  | tr '\n' '\0' | xargs -t -0 -n10 -P 16 rm -v

function shift(col) {
		_f=$(col)
		for (i=col; i<NF; i++) { $i = $(i+1) }
		NF--
		return _f
}
{
		ii = shift(1)
		fc[ii]++
		if (length(f[ii]) == 0) { 
				f[ii]=$0
				next
		}
}

f[ii] { 
		 # prefer the dupe with the longest name
		 # because that should mean it has been put into some subfolder.
		 old= length(f[ii])
		 new= length($0)
		 if (old == new ) { }
		 if (old < new ) { }
		 if (new < old ) {
				 o = f[ii]
				 f[ii] = $0
		 }
}
END {
	   	for (i in f) {
				if (fc[i] >= 2) {
						print  f[i] 
				}
		}
}
