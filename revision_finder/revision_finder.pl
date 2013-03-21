#!/usr/bin/perl
use strict;
use warnings;

if ($#ARGV != 1) {
	print "\nrevision_finder: given a text line fragment, display the svn revisions that changed it. To avoid harassing the svn server, the svn diff's are stored in a folder for later offline processing.\n";
	print "\nUsage: ./revision_finder.pl <svn folder name> <line fragment>\n";
	print "\nExample: ./revision_finder.pl ~/my_repository \"i want to know who changed the line that contains this text\"\n";
	exit;
}

die "Couldn't access folder $ARGV[0]!" if not -d $ARGV[0];

my $numRevisions;
my $svnOutput = `svn info $ARGV[0]`;
if ($svnOutput =~ m/Revision: (\d+)\n/) {
	$numRevisions = $1;
	print "Number of revisions: $numRevisions\n";
}
else {
	die "Couldn't recognize $ARGV[0] as an svn working copy";
}

system "svn log $ARGV[0] > log.txt";

# Obtain the name of the repository folder
my $diffFolder = $ARGV[0];
$diffFolder =~ s/\/$//;
$diffFolder =~ s/.*\///;

if (not -d $diffFolder) {
	mkdir $diffFolder or die "Could not create folder \"$diffFolder\" for saving diff's";
}

# Download the missing diff files
for (my $i = 0; $i < $numRevisions; ++$i) {
	my $filename = sprintf("%0".length($numRevisions)."d-%0".length($numRevisions)."d",$i,$i+1);
	if (not -e "$diffFolder/$filename" || (-e "$diffFolder/$filename" && -s "$diffFolder/$filename" == 0)) {
		print "Saving diff ".$i.":".($i+1)."...\n";
		system "svn diff $ARGV[0] -r ".$i.":".($i+1)." > $diffFolder/$filename";
		sleep 1; # Supercamouflage
	}
}

# Grep every diff file, to find lines which match the input text and were either an addition or a deletion
for (my $i = 0; $i < $numRevisions; ++$i) {
	my $filename = sprintf("%0".length($numRevisions)."d-%0".length($numRevisions)."d",$i,$i+1);
	my $result = `grep \"$ARGV[1]\" $diffFolder/$filename`;
	chomp $result;
	if (length($result) > 0) {
		my $revNumber = $i+1;
		my @lines = split '\n',$result;
		my $somethingActuallyChanged = 0;
		foreach my $line (@lines) { # Check if there is any matching line which was actually a modification
			if ($line =~ m/^\+/ or $line =~ m/^-/) {
				$somethingActuallyChanged = 1;
				last;
			}
		}
		if ($somethingActuallyChanged) {
			print "*********************************************************************************************************\n";
			my $log = `grep -A2 \"r$revNumber | \" log.txt`; # We'll show only the first line of the commit message
			my @logLines = split '\n',$log;
			foreach my $logLine (@logLines) {
				chomp $logLine;
				if (length($logLine) > 0) {
					print "$logLine\n";
				}
			}
			print "\n";
			foreach my $line (@lines) {
				if ($line =~ m/^\+/ or $line =~ m/^-/) {
					print "$line\n";
				}
			}
			print "*********************************************************************************************************\n";
			print "\n";
		}
	}
}

