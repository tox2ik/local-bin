#!/bin/sh
#
# echo 1 $1
# echo 2 $2
# echo 3 $3
# echo 4 $4
# echo 5 $5
# echo 6 $6
# echo 7 $7
# echo 8 $8
# echo 9 $9
# $ svn diff  basher.py  --diff-cmd /home/jaroslav/tmp/diff.svn.sh
# Index: basher.py
# ===================================================================
# 1 -u
# 2 -L
# 3 basher.py (revision 2996)
# 4 -L
# 5 basher.py (working copy)
# 6 .svn/text-base/basher.py.svn-base
# 7 /tmp/svn-UI5nmT
# 8
# 9
#--label
#diff -W 250 --tabsize=8 -p --suppress-common-lines -y "$6" "$7"
#vimdiff "$6" "$7"
sdiff -w 250 -s -t "$6" "$7"

