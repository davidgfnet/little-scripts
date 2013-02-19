#!/usr/bin/perl
use strict;
use warnings;

if ($#ARGV != 0) {
	print "\npaper_renamer: interactively (based on best guess) rename academic papers\n";
	print "\nUsage: paper_renamer.pl <foldername>\n\n";
	exit;
}

die "Couldn't access file $ARGV[0]!" if not -e $ARGV[0];
recursive($ARGV[0]);

sub recursive {
	my $name = $_[0];
	if (-d $name) {
		chdir $name;
		my @files = <*>;
		foreach my $file (@files) {
			recursive($file);
		}
		chdir '..';
	}
	else {
		if (`file \"$name\"` =~ m/PDF document, version/) {
			fix($name);
		}
	}
}

sub fix {
	my $filename = $_[0];
	system("pdftotext -bbox -f 1 -l 1 $filename TEMP.html");
	open FILE, "TEMP.html";
	my @lines = <FILE>;
	@lines = splice @lines, 0, 50;
	close FILE;
	system("rm TEMP.html");
	my $maxHeight = 0;
	foreach my $line (@lines) {
		chomp $line;
		if ($line =~ m/.*<word xMin="\d+\.\d+" yMin="(\d+\.\d+)" xMax="\d+\.\d+" yMax="(\d+\.\d+)">([^<]*)<\/word>.*/) {
			my $difference = $2 - $1;
			if ($difference > $maxHeight) {
				$maxHeight = $difference;
			}
		}
	}
	my $result = "";
	foreach my $line (@lines) {
		chomp $line;
		if ($line =~ m/.*<word xMin="\d+\.\d+" yMin="(\d+\.\d+)" xMax="\d+\.\d+" yMax="(\d+\.\d+)">([^<]*)<\/word>.*/) {
			my $difference = $2 - $1;
			if (abs($maxHeight - $difference) < 0.1) {
				if ($result eq "") {
					$result .= $3;
				}
				else {
					$result .= " $3";
				}
			}
		}
	}
	$result = substr $result, 0, 127;
	$result =~ s/ﬁ/fi/g;
	$result =~ s/ /_/g;
	$result .= '.pdf';
	if ($result ne $filename) {
		print "\n*******************************************\n\n";
		print "Rename\n";
		print "\n\"$filename\"\n";
		print "\nas\n";
		print "\n\"$result\"? (y/n) ";
		my $answer = <STDIN>;
		if ($answer eq "y\n") {
			system("mv $filename $result");
			print "\nDone!\n";
		}
	}
}

