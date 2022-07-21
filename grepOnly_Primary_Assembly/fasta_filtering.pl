#!/usr/bin/perl
#
# print only Primary Assembly in chromosome level from NCBI provided Assembly files (containing scaffolds, contigs or whatever)
#
use strict;
use warnings;

my $f_fa = shift;
	# find idx1 and change it to idx 2 

my $flag = 0;
open(FF,"zcat $f_fa|");
while(<FF>){
	chomp;
	if ($_ =~ /^>/){
	if ($_ =~ />.+Primary Assembly$/){
		$flag = 1;
	}else{
		$flag = 0;
	}}
	if ($flag == 1){
		print "$_\n";
	}
}
close(FF);
