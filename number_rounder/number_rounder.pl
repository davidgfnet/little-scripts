#!/usr/bin/perl
use strict;
use warnings;

if ($#ARGV != 2) {
	print "\nnumber_rounder: round all numbers in a file\n";
	print "\nUsage: number_rounder.pl <number_of_decimals> <input_file> <output_file>\n\n";
	exit;
}

my $decimals = $ARGV[0];
my $input_file = $ARGV[1];
my $output_file = $ARGV[2];

local $/ = undef;
open FILE, $input_file or die "Couldn't open file: $!";
binmode FILE;
my $string = <FILE>;
close FILE;
$string =~ s/(\d+\.\d+)/&round($1)/ge;
open FILE, ">$output_file" or die "Couldn't open file: $!";
print FILE $string;
close FILE;

sub round {
	sprintf("%.".$decimals."f", $_[0]);
}

