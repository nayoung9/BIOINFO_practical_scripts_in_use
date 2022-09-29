#!/usr/bin/perl
#
# parse Bssmooth results to contain chromosome, start, end, CpG number, group 1, 2 mean 


use strict;
use warnings;

my $f_in = shift;
open(F,"$f_in");
while(<F>){
	chomp;
	my @ar_tmp = split(/ /,$_);
	shift(@ar_tmp);
	my $chromosome  = shift(@ar_tmp);
	$chromosome =~ s/"//g;
	my $st = $ar_tmp[0];
	my $ed = $ar_tmp[1];
	my $n = $ar_tmp[5];
	my $group1_mean = $ar_tmp[11];
	my $group2_mean = $ar_tmp[12];
	print $chromosome."\t$st\t$ed\t$n\t$group1_mean\t$group2_mean\n";

}
close(F);

