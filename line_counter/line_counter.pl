#!/usr/bin/perl
use strict;
use warnings;

if ($#ARGV != 1 and $#ARGV != 2) {
	print "\nline_counter: print the total number of lines of every ASCII file that (optionally) matches a given regexp, down to N recursive levels (-1 for an unlimited number)\n";
	print "\nUsage: line_counter <foldername> <number of levels> [regexp]\n\n";
	exit;
}

die "Folder \"$ARGV[0]\" not found" unless -e $ARGV[0];
print "Total: ".recursive($ARGV[0],0,$ARGV[1],$ARGV[2])."\n";

sub recursive {
	my $result = 0;
	my $name = $_[0];
	my $currentLevel = $_[1];
	my $maximumLevel = $_[2];
	my $regexp = $_[3];

	if (-d $name) {
		chdir $name;
		my @files = <.*>;
		@files = (@files, <*>);
		foreach my $file (@files) {
			if ($file ne '.' and $file ne '..' and (!defined $regexp or $file =~ m/$regexp/) and ($currentLevel < $maximumLevel or $maximumLevel == -1)) {
				$result += recursive($file,$currentLevel+1,$maximumLevel,$regexp);
			}
		}
		chdir '..';
	}
	else {
		my $type = `file $name`;
		if ($type =~ m/ASCII/) {
			my $dir = `pwd`;
			chomp $dir;
			my $output = `wc -l $name`;
			$output =~ m/(\d+) .*/;
			$result += $1;
			print "$1\t$dir/$name\n";
		}
	}
	return $result;
}

