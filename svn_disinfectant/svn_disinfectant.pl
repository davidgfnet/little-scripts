#!/usr/bin/perl
use strict;
use warnings;

if ($#ARGV == -1) {
	print "\nsvn_disinfectant: recursively removes every .svn folder and its contents\n";
	print "\nUsage: svn_disinfectant.pl <foldername>\n\n";
	exit;
}

die "Folder \"$ARGV[0]\" not found" unless -e $ARGV[0];
recursive($ARGV[0]);
print "\n$ARGV[0] is clean!\n\n";

sub recursive {
	my $name = $_[0];
	if (-d $name) {
		if ($name eq '.svn') {
			disinfect($name);
		}
		else {
			chdir $name;
			my @files = <.*>;
			@files = (@files, <*>);
			foreach my $file (@files) {
				if ($file ne '.' and $file ne '..') {
					recursive($file);
				}
			}
			chdir '..';
		}
	}
}

sub disinfect {
	my $filename = $_[0];
	my $dir = `pwd`;
	chomp $dir;
	system "rm -rf $filename";
	print "Removed $dir/$filename\n";
}

