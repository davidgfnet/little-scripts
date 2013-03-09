#!/usr/bin/perl
use strict;
use warnings;

if ($#ARGV != 0) {
	print "\nnumber_inverter: invert the naming of the files with number names (or number+.format).\n";
	print "\nExample: [01.png, video.avi, 02.png, 04.png] get mapped to [04.png, video.avi, 02.png, 01.png]\n";
	print "\nUsage: number_inverter.pl <foldername>\n\n";
	exit;
}

die "Couldn't access folder $ARGV[0]" if not -d $ARGV[0];

my $separator = "###separator";

chdir $ARGV[0];
my @files = <*>;
my @goodFiles;
foreach my $file (@files) {
	if ($file =~ m/^(\d+)(\.\w+)?$/) {
		push @goodFiles, $file;
	}
}
@goodFiles = sort @goodFiles;
for (my $i = 0; $i <= $#goodFiles; ++$i) {
	rename $goodFiles[$i], $goodFiles[$#goodFiles-$i].$separator;
}
for (my $i = 0; $i <= $#goodFiles; ++$i) {
	rename $goodFiles[$#goodFiles-$i].$separator,$goodFiles[$#goodFiles-$i];
}

sub max {
	if ($_[0] > $_[1]) {
		return $_[0];
	}
	else {
		return $_[1];
	}
}

sub min {
	if ($_[0] > $_[1]) {
		return $_[1];
	}
	else {
		return $_[0];
	}
}

