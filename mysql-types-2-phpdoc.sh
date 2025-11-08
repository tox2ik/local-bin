#!/usr/bin/env bash -l
mydescr ${1:-store$} |
sed -f /home/jaroslav/src/sed/mysql-types-2-phpdoc.sed |
 awk -F% '/%/ { print "@property", $2, $1 }' | sed -E 's/\s+/ /g'
