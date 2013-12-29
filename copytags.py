from mutagen.id3 import ID3
from os.path import getsize, walk, isfile
import pprint


global ppr
ppr = None

def pp(what):
	global ppr
	if ppr is None: ppr = pprint.PrettyPrinter(indent=2)
	ppr.pprint(what)
	
#_from =    'Kid A (2000)/02 - Kid A.mp3'
#_to   = 'v3/Kid A (2000)/02 - Kid A.mp3'


bash = """#!/bin/bash 

path=$@

quality=v3
dir=$(dirname "$path")
file=$(basename "$path")

mkdir -p "$quality/$dir"

if [ ! -f "$quality/$path" ]; then
	echo converting $file
	in=$( cygpath -w "$path")
	out=$( cygpath -w "$quality/$path")
	lame -S --mp3input -V3 "$in" "$out"
else
	echo SKIP $path
fi
"""

# the above script transcodes everything in the current folder 
# to a fubfolder named '$quality'
# run like so: 

# find -type f -name \*3  \! -path './v3/*' -exec ./transcode.sh {} \;

if not isfile('transcode.sh'):
	with open('transcode.sh','wb') as bs:
		bs.write(bash)


def visit(arg, dirname, fnames):
	if dirname.startswith(arg): return
	print 'dir<%s>' % dirname
	for fn in fnames:
		if not fn.endswith('mp3'): return
		frm = '%s\\%s' %( dirname, fn)
		to = '%s\\%s' %( arg, frm)
		copy_tag(frm, to)

def copy_tag(original=None, destination=None):
	orig = ID3(original)
	copy = ID3()
	copy.update(orig)
	copy.save(destination)

#walk('.', visit, '.\\v3')
