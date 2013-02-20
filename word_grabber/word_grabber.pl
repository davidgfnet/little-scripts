#!/usr/bin/perl
use strict;
use warnings;

if ($#ARGV != 2) {
	print "\n";
	print "word_grabber: produce a list of words from a given language and linguistic category\n";
	print "(possibilities: those reachable from http://en.wiktionary.org/wiki/Category:All_parts_of_speech)\n\n";
	print "Usage: word_grabber.pl <language_name> <word_category> <output_file>\n";
	print "(use underscores as word separators)\n\n";
	print "Example: word_grabber.pl Catalan irregular_verbs list.txt\n\n";
	exit;
}

my $language_name = $ARGV[0];
my $whitespace_language_name = $language_name;
$whitespace_language_name =~ s/_/ /g;
my $word_category = $ARGV[1];
my $whitespace_word_category = $word_category;
$whitespace_word_category =~ s/_/ /g;
my $output_file = $ARGV[2];

open WORDS, ">$output_file";
my $nextPage = "http://en.wiktionary.org/wiki/Category:$language_name"."_"."$word_category";
my $foundNext = 1;
while ($foundNext) {
	system "wget \"$nextPage\" -O \"pag.html\"";
	$foundNext = 0;
	open FILE, "pag.html";
	my $line;
	while ($line = <FILE>) {
		chomp $line;
		if ($line =~ m/^(<ul>)?<li><a href="\/wiki\/[^"]*" title="[^"]*">([^<]*)<\/a><\/li>/) {
			print WORDS $2."\n";
		}
		elsif ($line =~ m/<a href="([^"]*)" title="Category:$whitespace_language_name $whitespace_word_category">next 200<\/a>/) {
			$nextPage = $1;
			$foundNext = 1;
		}
	}
	close FILE;
	$nextPage =~ s/&amp;/&/;
	$nextPage = "http://en.wiktionary.org".$nextPage;
	sleep 2;
}
close WORDS;
unlink "pag.html";
