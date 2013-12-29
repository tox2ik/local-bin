#!/usr/bin/perl 
#
# This is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This code is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this code; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
# 02111-1307, USA.
#
# Copyright 2003, Jon McClintock.
#
# $Id: goose,v 1.6 2003/05/17 03:04:45 jammer Exp $
#

use SOAP::Lite;
use Curses;
use AppConfig::State;
use AppConfig::File;

require HTML::TreeBuilder;
require HTML::FormatText;

my $state = AppConfig::State->new();
$state->define("key", { ARGCOUNT => ARGCOUNT_ONE, 
                        DEFAULT => "" });
$state->define("filter", { ARGCOUNT => ARGCOUNT_ONE,
			   DEFAULT => 1 });
$state->define("one_shot", { ARGCOUNT => ARGCOUNT_ONE,
			     DEFAULT => 0 });

my $cfgfile = AppConfig::File->new($state);

if (-f '/etc/goose.conf') {
    $cfgfile->parse('/etc/goose.conf');
}
if (-f ($ENV{HOME} . '/.goose.conf')) {
    $cfgfile->parse($ENV{HOME} . '/.goose.conf');
}

my $key = $state->get("key");
if ((!defined($key)) || ($key eq '') || (length($key) <= 1)) {
    print "You need to get a Google license key. Go to: \n" .
	  "\n" .
	  "    http://www.google.com/apis/\n" .
	  "\n" .
	  "and follow the instructions for creating a Google Account.\n" .
	  "\n" . 
	  "Once you have the key, add it to your configuration file,\n" .
	  "either the system-wide config file (/etc/goose.conf), or \n" .
	  "in your user-specific config file, named .goose.conf in your \n" .
	  "home directory.\n\n";
    exit(-1);
}

# Parse any command line arguments.
PARSELOOP: while (($#ARGV >= 0) && ($ARGV[0] =~ /^-/)) {
    if ($ARGV[0] eq "-1") {
	$state->set("one_shot", 1);
    } elsif ($ARGV[0] eq "-a") {
	$state->set("filter", 0);
    } elsif ($ARGV[0] eq "--") {
	last PARSELOOP;
    } else {
	print "Unknown option '$ARGV[0]'\n";
	undef @ARGV;
    }
}

if ($#ARGV < 0) {
    print "usage: goose [-1] [-a] [--] [one or more search terms]\n" .
	  "  -1		One shot search--exit after opening one result\n" .
	  "  -a		Show all results (turn Google's filtering off)\n" .
          "  --		Stop parsing command-line options\n";
    exit(-1);
}

# Setup Curses.
initscr();
noecho();
cbreak();
clear();

# Get the screen size into two globals.
getmaxyx($rows, $columns);

# The chunkSize is the number of results we display on one screen.
$chunkSize = int(($rows - 2) / 4);

# The currentChunk is the result number of the element currently at the top of
# the screen.
$currentChunk = 0;

# currentSelection is the result number of the current selection.
$currentSelection = 0;

# fetchedResultCount shows how many search results we've fetched from Google.
$fetchedResultCount = 0;

# totalResultCount shows how many total search results Google says there are.
$totalResultCount = 0;

# searchResults is an array of the search result structures.
@searchResults;

my $query = join(" ", @ARGV);

my $googleSearch = SOAP::Lite->service("file:/usr/lib/goose/GoogleSearch.wsdl");

#
# The MAINLOOP is the giant loop surrounding the bulk of the code. Each
# iteration through the MAINLOOP causes a redraw of the whole screen, 
# possibly resulting in the fetching of more results from the server. 
#
# The MAINLOOP contains the INPUTLOOP, which can iterate several times,
# processing user input.
# 
MAINLOOP: while (1) {

    # Write the status line.
    move(0, 0);
    clrtoeol();
    attron(A_REVERSE);
    addstr(0, 0, "Fetching search results...");
    attrset(A_NORMAL);
    refresh();

    # If the last result on the screen that we are about to draw is beyond
    # the set of results we've already fetched, we need to fetch more
    # results.
    FETCHLOOP: while (($currentChunk + $chunkSize) > $fetchedResultCount) {
	# Execute the query and get more results. Google limits you to 
	# 10 results at a time.
	my $result = $googleSearch->doGoogleSearch($key, $query, 
				$fetchedResultCount, 10,
				$state->get("filter") ? "true" : "false", 
				"", "false", "", "latin1", "latin1");
	if (!defined($result)) {
	    print_message_and_exit(
		    "Error executing query.\n", 0);
	}

	# Update the result counters.
	$totalResultCount = $result->{'estimatedTotalResultsCount'};
	if ($result->{'endIndex'} > $fetchedResultCount) {
	    $fetchedResultCount = $result->{'endIndex'};
	}

	if (($result->{'startIndex'} == 0) ||
	    ($totalResultCount == 0)) {
	    print_message_and_exit(
		    "No matching search results for the query '$query'\n", 0);
	}

	# Copy the results into the @searchResults array.
	for (my $i = 0; 
	     $i <= ($result->{'endIndex'} - $result->{'startIndex'}); 
	     $i++) {
	    $searchResults[$result->{'startIndex'} + $i - 1] = 
				$result->{'resultElements'}[$i];
	}

	# If we get an incomplete fetch, we know we've reached the end
	# of the results.
	if (($fetchedResultCount == $totalResultCount) ||
	    (($result->{'endIndex'} - $result->{'$startIndex'}) < 10)) {
	    $totalResultCount = $fetchedResultCount;
	    last FETCHLOOP;
	}
    }

    # Clear the screen.
    clear();

    # Draw the result statistics line.
    attron(A_REVERSE);
    addstr(0, 0, "About $totalResultCount results for '" . 
	    substr($query, 0, 50) . "'");
    addstr(1, 0, "Showing results " .
	    ($currentChunk + 1) . " to " . 
	    (($currentChunk + $chunkSize) > $totalResultCount ? 
	    	$totalResultCount : ($currentChunk + $chunkSize)) . ":");
    attrset(A_NORMAL);
    refresh();

    # Print each result.
    for ($i = $currentChunk; 
	 ($i < ($currentChunk + $chunkSize)) && ($i < $fetchedResultCount);
	 $i++) {
	print_result($i);
    }

    # The INPUTLOOP loops on the user's input until they quit, select a
    # search result for viewing, or move the selection off the visible
    # screen.
    INPUTLOOP: while (1) {
	print_input_prompt();

	my $ch = getch();

	# Up and down are represented by a sequence of characters, starting
	# with '^[' (escape) and '[', followed by the distinguishing character,
	# 'A' for up, and 'B' for down.
	if (($ch eq '') && (getch() eq '[')) {
	    $ch = getch();
	    if ($ch eq 'B') { 
		if (next_selection()) {
		    next MAINLOOP;
		}
		next INPUTLOOP;
	    } elsif ($ch eq 'A') {
		if (previous_selection()) {
		    next MAINLOOP;
		}
		next INPUTLOOP;
	    }
	}

	# If the user presses enter, load the current selection in their
	# web browser. Note here that we depend on the Debian-specific
	# url_handler.sh script.
	if ($ch eq "\n") {
	    $element = $searchResults[$currentSelection];
	    move($rows - 1, 0);
	    clrtoeol();
	    addstr($rows - 1, 0,
		    "Opening URL:  $element->{'URL'}");
	    refresh();

	    standend();
	    endwin();

	    if ($state->get("one_shot")) {
		exec("/etc/urlview/url_handler.sh '$element->{'URL'}'");
	    } else {
		system("/etc/urlview/url_handler.sh '$element->{'URL'}'");
	    }
	}

	# The user wants to quit. We should probably let them.
	if (($ch eq 'q') || ($ch eq 'Q')) {
	    last MAINLOOP;
	}

	# Pressing space causes the display to shift down one page.
	if ($ch eq ' ') {
	    $currentChunk += $chunkSize;
	    $currentSelection += $chunkSize;
	    next MAINLOOP;
	}

	# We got an unrecognized keypress, let the user know.
	move($rows - 1, 0);
	clrtoeol();
	attron(A_REVERSE);
	addstr($rows - 1, 0,
		"Invalid key ($ch) pressed, try again...");
	refresh();
	sleep(1);

	next INPUTLOOP;
    }
}

# Shut down Curses.
standend();
clear();
refresh();
endwin();

# Prints the user input prompt.
sub print_input_prompt
{
    move($rows - 1, 0);
    clrtoeol();
    addstr($rows - 1, 0,
	    "Select result " . ($currentChunk + 1) . "-" . 
	    ($currentChunk + $chunkSize) . 
	    ", press 'q' to quit, or -return- for more: ");
    attrset(A_NORMAL);
    refresh();
}

# Prints the given result number. Assumes that the given result number is
# currently within the visible region. 
sub print_result
{
    my ($number) = @_;

    my $element = $searchResults[$number];
    my $y = ($number % $chunkSize) * 4 + 2;
    my $x = 0;

    # If the given result is the selected result, draw it in reverse.
    if ($number == $currentSelection) {
	attron(A_REVERSE);
    }

    # Draw the result number and the URL, in bold.
    attron(A_BOLD);
    addstr($y, $x,
	   $number + 1 . ".");
    addstr($y, $x + 4,
	   substr($element->{'URL'}, 0, $columns - ($x + 4)));
    attroff(A_BOLD);

    # Get the HTML snippet included with the result. We do some processing
    # to remove leading and trailing whitespace, as well as the ellipses
    # Google likes to put at the beginning and the end, and any line breaks.
    my $snippet = $element->{'snippet'};
    $snippet =~ s/^\s*//;
    $snippet =~ s/\s*$//;
    $snippet =~ s/^<b>\.\.\.<\/b>//;
    $snippet =~ s/<b>\.\.\.<\/b>$//;
    $snippet =~ s/<br>//;

    # Parse the HTML snippet into plain text.
    my $tree = HTML::TreeBuilder->new_from_content($snippet);
    my $formatter = HTML::FormatText->new(leftmargin => 4, 
	    			       rightmargin => $columns-5);
    my $text = $formatter->format($tree);

    # Now draw up to three lines of the snippet.
    my @lines = split(/\n/, $text, 3);
    my $count = 0;
    while (@lines)
    {
	my $line = shift(@lines);
	$line =~ s/^\s*//;
	$line =~ s/\n.*$//;

	addstr($y + $count + 1, $x + 4, $line);
	$count++;
    }

    attrset(A_NORMAL);
}

# Advance the current selection to the next result. Returns 1 if the screen
# should be redrawn because the visible region has changed, zero otherwise.
sub next_selection
{
    # If the current selection is the very last result element, do nothing.
    if ($currentSelection == ($totalResultCount - 1)) {
	return 0;
    }

    # If the current selection is at the bottom of the screen, move the
    # visible region and return 1 to force a redraw.
    if (($currentSelection % $chunkSize) == ($chunkSize - 1)) {
	$currentChunk += $chunkSize;
	$currentSelection++;
	return 1;
    } 

    # We use a temporary variable so that we can redraw the old selection
    # as normal text.
    my $sel = $currentSelection;
    $currentSelection++;

    print_result($sel);
    print_result($currentSelection);

    return 0;
}

# Set the current selection to the previous result. Returns 1 if the screen
# should be redrawn because the visible region has changed, zero otherwise.
sub previous_selection
{
    if ($currentSelection == 0) {
	return 0;
    }

    # If the current selection is at the top of the screen, move the visible
    # region and return 1 to force a redraw.
    if (($currentSelection % $chunkSize) == 0) {
	if ($currentChunk >= $chunkSize) {
	    $currentChunk -= $chunkSize;
	} else {
	    $currentChunk = 0;
	}

	$currentSelection--;
	return 1;
    }

    # We use a temporary variable so that we can redraw the old selection
    # as normal text.
    my $sel = $currentSelection;
    $currentSelection--;

    print_result($sel);
    print_result($currentSelection);

    return 0;
}

# Clean up the Curses environment, print the given error message, and
# quit.
sub print_message_and_exit
{
    my ($message, $retval) = @_;

    standend();
    clear();
    refresh();
    endwin();

    print $message;

    exit($retval);
}

=head1 NAME

goose - Search Google using the command line.

=head1 SYNOPSIS

B<goose> [B<one or more search terms>]

=head1 OPTIONS

=over 8

The only command line parameters are the search terms to pass to Google. 
Keep in mind that the usual shell escaping rules need to be observed.

=back

=head1 FILES

Goose uses configuration files to store the Google web API key. They
both observe the same format. An example is provided in 
/usr/share/doc/goose/goose.conf.example.

=over 8

=item B</etc/goose.conf>

The system-wide configuration file.

=item B<$(HOME)/.goose.conf>

The user-specific configuration file. The values in this file override
the values in the system-wide configuration file.

=back

