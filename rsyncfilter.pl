#!/usr/bin/perl
################################################################################
# Copyright (c) 2011 Martin Scharrer <martin@scharrer-online.de>
# This is open source software under the GPL v3 or later.
################################################################################
use strict;
use warnings;

my $include = {};

sub add_include {
    INCLUDE_PATH:
    foreach my $path (@_) {
        chomp $path;
        my @dirs = split (/\//, $path);
        shift @dirs if @dirs and $dirs[0] eq '';
        my $lastdir = pop @dirs;
        my $ref = $include;
        foreach my $dir (@dirs) {
            my $dirref = $ref->{$dir};
            if (defined $dirref) {
                if (ref $dirref ne 'HASH') {
                    warn "Warning: directory '$dir' of '$path' already fully included!\n";
                    next INCLUDE_PATH;
                }
                $ref = $dirref;
            } else {
                my $newdir = {};
                $ref = $ref->{$dir} = $newdir;
            }
        }
        if (exists $ref->{$lastdir} && $ref->{$lastdir} ne '1') {
            warn "Warning: '$path' now fully included!\n";
        }
        $ref->{$lastdir} = '1';
    }
}

sub print_include {
    my $pdir = shift;
    my $h    = shift;
    print "+ $pdir/\n";
    foreach my $dir (sort keys %$h) {
        my $value = $h->{$dir};
        if (ref $value ne 'HASH') {
            print "+ $pdir/$dir/***\n";
            ## For older rsync versions use the following instead:
            #print "+ $pdir/$dir/\n";
            #print "+ $pdir/$dir/**\n";
        }
        else {
            print_include ("$pdir/$dir", $value);
        }
    }
    print "- $pdir/*\n";
}

if (@ARGV) {
    add_include (@ARGV);
}
else {
    add_include <STDIN>;
}

print_include ('', $include);

__END__
