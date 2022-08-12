#!/usr/bin/perl
#
#
use strict;
use warnings;

my $f_fa = shift;
my $f_format = shift;
my $idx1 = shift;
my $idx2 = shift;
	# find idx1 and change it to idx 2 (from f_format, tab-deliminated 
  # idx starts from 0 innately
  
  
my %hs_format = ();
open(F,$f_format);
while(<F>){
	chomp;
	if ($_ =~ /^#/){next;}
	my @ar_tmp = split(/\t/,$_);
	$hs_format{$ar_tmp[$idx1]} = $ar_tmp[$idx2];
}
close(F);

open(FF,"zcat $f_fa|");
while(<FF>){
	chomp;
	if ($_ =~ />(\S+) /){
		#print $1;
		print ">".$hs_format{$1}."\n";
	}else{
		print $_."\n";
	}
}
close(FF);
