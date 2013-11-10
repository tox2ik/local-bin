#!/bin/sh
Editor="/usr/bin/vimdiff"
LEFT=${6}
RIGHT=${7}
### the specified command: 
#1 base
#2 theirs
#3 mine
#4 merged
#5 wcfile
$Editor $LEFT $RIGHT
