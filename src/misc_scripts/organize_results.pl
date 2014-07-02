#!/usr/bin/perl -w

###############################################################################
# Setup
###############################################################################

use strict;
use File::Path qw(make_path);
use File::Basename;
use File::Copy;

if (scalar(@ARGV) == 0) {
	die "Expected to see one parameter, the results dir."
}

###############################################################################
# Main
###############################################################################

my $results_dir = shift @ARGV;
my @files = <"$results_dir*">;

my $images_dir = "$results_dir/images";
make_path($images_dir);

for (@files) {
	next if -d $_;

	move($_,"$images_dir");
}

@files = <"$images_dir/*">;

my @unrefed_files;

for (@files) {
	my $filename = basename($_);
	if ($_ =~ /bsa_pre_(.*?)_\d+/) {
		make_path("$results_dir/$1/Venus");
		system("ln -s \"../../images/$filename\" \"$results_dir/$1/Venus/$filename\"\n");
	} elsif ($_ =~ /cna_pre_(.*?)_\d+/) {
		make_path("$results_dir/$1/FRET");
		system("ln -s \"../../$filename\" \"$results_dir/$1/FRET/$filename\"\n");
	} elsif ($_ =~ /SaveParams/) {
		#don't mark SaveParams for deletion
	} else {
		push @unrefed_files, $_;
	}
}

unlink @unrefed_files;
