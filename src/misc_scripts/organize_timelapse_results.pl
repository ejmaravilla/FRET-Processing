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
die "Couldn't Find $results_dir" if (! -e $results_dir);

my @files = <$results_dir*>;

my $images_dir = "$results_dir/images";
make_path($images_dir);

for (@files) {
	next if -d $_;
	
	print "$_\n";
	
	move($_,"$images_dir");
}

@files = <$images_dir/*>;

my @unrefed_files;

for (@files) {
	my $filename = basename($_);
	if ($_ =~ /bsa_pre_(.*?)_w.*_s(\d+)_t\d+/) {
		my $target_folder = "$results_dir/$1/$2/Acceptor";
		make_path($target_folder);
		system("ln -s \"../../../images/$filename\" \"$target_folder/$filename\"\n");
	} elsif ($_ =~ /cna_pre_(.*?)_w.*_s(\d+)_t\d+/) {
		my $target_folder = "$results_dir/$1/$2/FRET";
		make_path("$target_folder");
		system("ln -s \"../../../images/$filename\" \"$target_folder/$filename\"\n");
	} elsif ($_ =~ /SaveParams/) {
		#don't mark SaveParams for deletion
	} else {
		push @unrefed_files, $_;
	}
}

# unlink @unrefed_files;
