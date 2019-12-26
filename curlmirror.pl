#!/usr/bin/perl
#
# curlmirror.pl
#
# Mirrors a web site by using curl to download each page.
# The result is stored in a directory named "dest" by default.
# Temporary files are stored in "/tmp".
#
# Author: Kjell.Ericson@haxx.se
#
# History:
#
# 1999-11-19 v0.9 - Kjell Ericson - First version
# 1999-11-22 v0.10 - Kjell Ericson - Added some more flags
# 1999-12-06 v0.11 - Kjell Ericson - Relative paths were not correctecd
# 1999-12-06 v1.0  - Kjell Ericson - Satisfied and updated to v1.0
# 1999-12-07 v1.1  - Kjell Ericson - Added "-p"
# 1999-12-08 v1.2  - Kjell Ericson - Added "-l" and "-c"
# 1999-12-13 v1.3  - Kjell Ericson - Added match for images in stylesheets
# 2000-08-07 v1.4  - Kjell Ericson - Handles both ' and " in links.
# 2000-08-15 v1.5  - Kjell Ericson - Added -I.
# 2000-08-16 v1.6  - Kjell Ericson - Added multiple -I and -B.
# 2002-01-23 v1.7  - Anthony Thyssen - Changed the destination filename
# 2002-07-14 v1.8  - Kjell Ericson - Corrected a temp-filename error
# 2007-10-07 v1.9  - Kjell Ericson - Corrected the URL-add calculation
# 2013-04-03       - Kjell Ericson - Added Referer to all gets
# 2014             - Kjell Ericson - Added -Br.  Made regex case insensitive.
# 2015-01-18       - Kjell Ericson - Added -n (different destination name)
#                                  - Added -r and -R (regex of files to save)
#                                  - Added https support
# 2015-03-10       - Koen Van Impe - Add SOCKS5 support

$max_deep=1000;
$max_size=500;

$dest_dir="dest";
$default_name="index.html";
$tmp="/tmp";
$filecounter=0;
$save_regex = "";
$tor_proxy=0;

#$debug = 1;

# For faster handling we have this regex:
$nonhtmlfiles="jpg|gif|png|zip|doc|txt|pdf|exe|java";

$help=
    "Usage: curlmirror.pl [flags] [url]\n".
    "\n".
    "-a <args>  : Curl specific arguments\n".
    "-B <url>   : Only retrieve URL below this URL (default is [url]). Option may be repeated.\n".
    "-Br <url>  : Same as -B, but <url> is a regex.\n".
    "-b <name>  : Pattern that will be stripped from filename.\n".
    "-c         : Ignore CGI's (i.e URL's with '?' in them) (default off).\n".
    "-d <number>: Depth to scan on (default unlimited).\n".
    "-f         : Flat directory structure is made (be careful).\n".
    "-F         : Flat directory structure but use path in filename.\n".
    "-i <name>  : Default name for unknown filenames (default is 'index.html').\n".
    "-I <regex> : Don't handle files matching this pattern (default is \"\").\n".
    "-l         : Only load HTML-pages - no images (default is to load all).\n".
    "-n         : Use last part of URL as filename\n".
    "-o <dir>   : Directory to output result in (default is 'dest').\n".
    "-s <number>: Max size in Mb of downloaded data (default $max_size Mb)\n".
    "-r <regex> : Regex of content type that shall be saved.\n".
    "-R <regex> : Regex of url that shall be saved.\n".
    "-p         : Always load images (default is not to).\n".
    "-t <dir>   : Temporary directory (default is '/tmp').\n".
    "-T         : With SOCKS5 support (--socks5 127.0.0.1:9150).\n".
    "-v         : Verbose output.\n".
    "\n".
    "Example:\n".
    "curlmirror.pl http://www.perl.com/\n".
    "\nAuthor: Kjell.Ericson\@haxx.se\n";

for ($i=0; $i<=$#ARGV; $i++) {
    $arg=$ARGV[$i];
    if ($arg =~ s/^-//) {
        if ($arg =~ m/\?/) {
            print $help;
            exit();
        }
        if ($arg =~ m/a/) {
            $curl_args=$ARGV[++$i];
        }
        if ($arg =~ s/Br//) {
            my $base=$ARGV[++$i];
            push @basematch, $base;
        }
        if ($arg =~ m/B/) {
            $base=$ARGV[++$i];
            if ($base =~ m/(https?:\/\/[^\/]*)/i) {
		$base=~ s/([+*~^()\\])/\\$1/g; # escape chars
	    }
            push @basematch, $base;
        }
        if ($arg =~ m/I/) {
            push @ignorepatt, $ARGV[++$i];
        }
        if ($arg =~ m/b/) {
            $strip_from_file=$ARGV[++$i];
        }
        if ($arg =~ m/c/) {
            $ignore_cgi=1;
        }
        if ($arg =~ m/d/) {
            $max_deep=$ARGV[++$i];
        }
        if ($arg =~ m/o/) {
            $dest_dir=$ARGV[++$i];
            $dest_dir=~ s/\/$//g;
        }
        if ($arg =~ m/r/) {
            $save_content_regex = $ARGV[++$i];
        }
        if ($arg =~ m/R/) {
            $save_url_regex = $ARGV[++$i];
        }
        if ($arg =~ m/t/) {
            $tmp=$ARGV[++$i];
            $tmp=~ s/\/$//g;
        }
        if ($arg =~ m/s/) {
            $max_size=$ARGV[++$i];
        }
        if ($arg =~ m/i/) {
            $default_name=$ARGV[++$i];
        }
        if ($arg =~ m/l/) {
            $only_html=1;
        }
        if ($arg =~ m/v/) {
            $verbose=1;
        }
        if ($arg =~ m/p/) {
            $picture_load=1;
        }
        if ($arg =~ m/f/) {
            $flat=1;
        }
        if ($arg =~ m/F/) {
            $flat=2;
        }
        if ($arg =~ m/T/) {
            $tor_proxy=1;
        }
        if ($arg =~ m/n/) {
            $short_name = 1;
        }
    } else { #default
        $start=$arg;
    }
}

if ($tor_proxy == 1) {
    $curl="curl --socks5 127.0.0.1:9150 -k -s $curl_args ";
}
else {
    $curl="curl -k -s $curl_args ";
}

if ($base eq "") {
    if ($start !~ m/(https?:\/\/.+\/)/i) {
        if ($start =~ m/(https?:\/\/.+)/i) {
            $start.="/";
        } else {
            print "***Malformed start URL ($start)\n";
            die($help);
        }
    }
    $base=$start;
    $base=~ s/\/[^\/]+$/\//; # strip docname
    $base=~ s/([+*~^()\\])/\\$1/g; # escape chars
    push @basematch, $base;
}


$follow_link{"start"}=0;

$linktmp="[ \n\r]*=[ \r\n]*)([\"'][^\"']*[\"']|[^ )>]*)";
%follow=(
         "(<[^>]*a[^>]+href$linktmp", "link",
         "(<[^>]*area[^>]+href$linktmp", "link",
         "(<[^>]*frame[^>]+src$linktmp", "link",
         );
if ($only_html == 0) {
    %follow=(%follow,
             "(BODY[^>]*\{[^}>]*background-image:[^>}]*url[(])([^\}>\) ]+)", "img", # for stylesheets
             "(<[^>]*img[^>]+src$linktmp", "img",
             "(<[^>]*body[^>]+background$linktmp", "img",
             "(<[^>]*applet[^>]+archive$linktmp", "archive",
             "(<[^>]*td[^>]+background$linktmp", "img",
             "(<[^>]*tr[^>]+background$linktmp", "img",
             "(<[^>]*table[^>]+background$linktmp", "img",
             );
}

$deep=0;
$found=1;
while ($found && $deep<$max_deep) {
    $found=0;
    my @links_to_follow = keys %follow_link;
    while ($#links_to_follow >= 0) {
	$url = shift @links_to_follow;
        $current_depth=$follow_link{$url};
#        print STDERR ">$url $current_depth\n";
        if ($current_depth == $deep && $current_depth>=0 &&
            $total_size<$max_size*1024*1024) {
            $found=1;
            $current_depth++;
            if ($url eq "start") {
                delete $follow_link{$url};
                $url=$start;
                $url="stdin" if ($url eq "");
                $start="";
            }
            $follow_link{$url}=-1;
            $stop=0;

            $status_code=0;
            $content_type="";
            $real_url=$url;
            $real_url=~s/#(.*)//; # strip bookmarks before loading
            if ( $url !~ m/[ \n\r]/) {
                $filecounter++;
                $this_file_name=$real_url;
		$this_file_name =~ s/%([a-fA-F0-9][a-fA-F0-9])/chr hex $1/eg;
		if ($short_name) {
		    $this_file_name =~ s/^.*\/(.+\?.*)/$1/ || # replace this
			$this_file_name =~ s/^.*\/(.+)/$1/; # ...or this
		} else {
		    if (length($this_file_name) > 40) {
			$real_url =~ m/(\.\w{3,5})$/;
			$this_file_name = substr($this_file_name, 0, 37) . $1;
		    }
		}
		$this_file_name = $filecounter . "-" . $this_file_name;
		$this_file_name=~ s/[^\w\d_.-]+/_/g;
                $content_type="";

                print "Get $deep:$url ($real_url)\n" if ($verbose);
		my $cmd = "$curl -e \"$referer{$url}\" -D - -o \"$tmp/$this_file_name\" \"$real_url\"";
                print "$cmd\n" if ($verbose);
                $head=`$cmd`;
                $filenames{$real_url}=$this_file_name;
                if ($head =~ m/Location: *["]?(.*)["]?/i) {
                    $loc=$1;
                    $loc=~ s/[\r\n]//g;
                    $loc=merge_urls($real_url, $loc);
                    if (accept_url($loc) ||
                        ($picture_load && $linktype{$real_url} eq "img")) {
                        print "1 unlink \"$tmp/$this_file_name\"\n" if (debug);
                        unlink "$tmp/$this_file_name";
                        delete $filenames{$real_url};
                        $real_url=$loc;
                        $url=$loc;
                        print "Reget $deep:$url\n" if ($verbose);
			my $cmd = "$curl -e \"$referer{$url}\" -D - -o \"$tmp/$this_file_name\" \"$real_url\"";
			print "$cmd\n" if ($verbose);
			$head=`$cmd`;
                        $filenames{$real_url}=$this_file_name;
                        $follow_link{$real_url}=-1;
                    }
                }

                if ($head =~ m/^HTTP[^\n\r]* ([0-9]+) ([^\n\r]*)/s) {
                    $status_code=$1;#." ".$2;
                }
                if ($head =~ m/[\n\r]Content-Type:(.*?)[\r\n]/si) {
                    $content_type=$1;
                }
                $linktype{$real_url}=$content_type;
                if ($content_type !~ m/html/i) {
                    if ($only_html ||
			!saveable_file($content_type, $real_url)) { # remove this file
                        $total_size-=-s "$tmp/$this_file_name";
                        print "2 unlink \"$tmp/$this_file_name\" $content_type\n\n" if (debug);
                        unlink "$tmp/$this_file_name";
                        delete $filenames{$real_url};
                    }
                } else {
                    if ($current_depth<$max_deep) {
			$text=`cat "$tmp/$this_file_name"`;
			if (saveable_file($content_type, $real_url)) {
			    $total_size+=-s "$tmp/$this_file_name";
			    $linktype{$real_url}="text/html";
			} else {
			    print "Skip $real_url $content_type\n";
			    print "3 unlink \"$tmp/$this_file_name\"\n" if (debug);
			    unlink "$tmp/$this_file_name";
			}
                        $text="" if ($url =~ m/\#/);
                        foreach $search (keys %follow) {
                            while ($text =~ s/$search//si) {
                                $link=$2;
                                $link=~ s/[\"\']//g;
                                $link=~ s/#.*//;
                                $newurl=merge_urls($url, $link);
                                if ($ignore_cgi==0 || $newurl !~ m/\?/) {
                                    if ($follow_link{$newurl} eq "" &&
					(accept_url($newurl) ||
					 ($picture_load && $follow{$search} eq "img"))) {
                                        if (!exists $follow_link{$newurl}) {
                                            if ($only_html == 0 ||
                                                $newurl !~ m/\.($nonhtmlfiles)$/i) {
                                                $follow_link{$newurl}=$current_depth;
						$referer{$newurl} = $url;
						if ($picture_load && $follow{$search} eq "img") {
						    unshift @links_to_follow, $newurl; # Load images faster
						}
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    $deep++;
}
print "Max size exceeded ($total_size bytes)!\n" if ($total_size>=$max_size*1024*1024);
print "Total size loaded:$total_size bytes\n" if ($verbose);

foreach $url (keys %filenames) {
    local $destname=$url;
    $destname=~ s/$basematch[0]//i;
    local $destdir=$destname;

    $destdir="" if ($destdir !~ m/\//);
    $destdir =~ s/\/[^\/]*$/\//;

    $destname=~ s/^.*\///g;
    $destname=~s/#(.*)//;
    local $bookmark=$1;

    $destname=~ s/[^a-zA-Z0-9.]/_/g; # strip chars we don't want in a filename
    $destdir=~ s/$strip_from_file// if ($strip_from_file ne "");
    $destdir=~ s/^([^\/]+):\/\//$1_/;
    $destdir=~ s/[^a-zA-Z0-9.\/_]/_/g;
    $destdir=~ s/(^\/)|(\/$)//g; # strip trailing/leading slashes

    if ($flat) {
        if ($flat==2) {
            $destdir=~ s/[\/:]/_/g;
            $destdir.="_";
        } else {
            $destdir="";
        }
        `mkdir -p "$dest_dir"`;
    } else {
        local $tmp="$dest_dir/$destdir";
        $tmp=~ s/^\///g;
        `mkdir -p "$tmp"`;
        $destdir.="/" if ($destdir ne "");
    }
    $destname=$default_name if ($destname eq "");
    $destname=$destdir.$destname if ($destdir ne "");
    if (($linktype{$url} =~ m/html/i) && ($destname !~ m/\.[s]?htm/i)) {
        $destname.=".html";
    }
    $destfile{$url}=$destname;
}

foreach $url (keys %filenames) {
    $name=$filenames{$url};
    $destname=$destfile{$url};

    if ($linktype{$url} !~ m/html/) {
        `mv "$tmp/$name" "$dest_dir/$destname"`;
    } else {
        $text=`cat "$tmp/$name"`;
        foreach $search (keys %follow) {
            $text=~ s/$search/"$1\"".make_file_relative($url,merge_urls($url, $2))."\""/sgie;
        }
        if (open(OUT, ">$dest_dir/$destname")) {
            print OUT $text;
            close(OUT);
        } else {
            print STDERR "Couldn't save file '$dest_dir/$destname'\n";
        }
	print "4 unlink \"$tmp/$name\"\n" if (debug);
        unlink "$tmp/$name";
    }
}

# Input: Base-URL, MakeRelative-URL
#
# Function: Convert and return "MakeRelativ-URL" to be relative
# to "Base-URL".
#
sub make_file_relative
{
    local ($from, $to)=@_;
    local $result="";
    local $sourcename=$destfile{$from};
    local $destname;
    local $bookmark;


    if ($to=~ s/(\#.*)$//) { # extract bookmarks
        $bookmark=$1;
    }

    $destname=$destfile{$to};

    if ($destname eq "") {
        return $to.$bookmark
    }


    $sourcename="" if ($sourcename !~ m/\//);

    $sourcename=~ s/\/[^\/]*$/\//; #strip filename
    do {
        $sourcename=~ m/^([^\/]*\/)/;
        local $dir=$1;
        if ($dir ne "") {
            $dir=~ s/([*.\\\/\[\]()+|])/\\$1/g;
            if ($destname =~ s/^$dir//) {
                $sourcename=~ s/^$dir//;
            } else {
                $dir="";
            }
        }
    } while ($dir ne "");
    $sourcename=~ s/[^\/]+\//..\//g; # Relative it with some ../

    $result="$sourcename$destname";
    $result=~ s/^\///g;

    return $result.$bookmark;
}


# Function: If you are viewing location "$base" which is a full URL, and
# click on "$new" that can be full or relative - where do you get? That
# is what this function returns.
#
# Input: base-URL, new-URL (where to go)
# Returns: a full format new-URL (without bookmark)
#
sub merge_urls
{
    local ($org, $new)=@_;
    local $url, $new;

    $new =~ s/[\"\']//g;

    if ($new =~ m/^\w+:/) {
        $url=$new;
    } elsif ($new eq "") {
        $url=$org;
    } else {
        if ($org =~ m/^(\w+):\/\/([^\/]*)(.*)$/) {
            local $prot=$1;
            local $server=$2;
            local $pathanddoc=$3;
            local $path;
            local $doc=$3;
            if ($pathanddoc=~ m/^(.*)\/(.*)$/) {
                $path=$1;
                $doc=$2;
            }
            $doc=~s/#(.*)//;
            local $bookmark=$1;

            if ($new =~ m/^#/) {
                $url="$prot://$server$path/$doc$new";
            } elsif ($new =~ m/^\//) {
                $url="$prot://$server$new";
            } else {
                $url="$prot://$server$path/$new";
                while ($url =~ s-(^[\w]+://.*/)\.\./-$1- ||
                       $url =~ s-(^[\w]://.*/.*?/)[^/]*/\.\./-$1-) {
                }
                while ($url =~ s/\.\///){};
            }
        }

    }
#    print STDERR "'$org' + '$new' = '$url'\n";
    return $url;
}

sub accept_url
{
    local ($url)=@_;
    local $ret=0;
    for (@basematch) {
        if ($url =~ m/$_/i) {
            $ret=1;
	    last;
        }
    }
    if ($ret == 0) { # No basematch
	print "Wrong base  $url\n";
	return 0;
    }

    for (@ignorepatt) {
        if ($url =~ m/$_/) {
	    print "Ignore      $url\n";
            return 0;
        }
    }
    print "Match       $url\n";
    return 1;
}

sub saveable_file
{
    my ($content_type, $url) = @_;
    if ($save_content_regex && $content_type !~ m/$save_content_regex/i) {
	return 0;
    }
    if ($save_url_regex && $url !~ m/$save_url_regex/i) {
	return 0;
    }
    return 1;
}
