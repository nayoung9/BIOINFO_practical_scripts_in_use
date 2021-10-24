#!/usr/bin/perl
#
#
#
use strict;
use warnings;

my $f_in = shift;

my ($gst, $ged) = (0,0);
my $gid = "";
my $tid = "null";
my $count = 0;

open(F,"$f_in");
while(<F>){
	chomp;
	if ($_ =~ /^#/){next;}
	my @ar_tmp = split(/\t/,$_);
	my @ar_tmp2 = split(/;/,$ar_tmp[8]);
	if ($ar_tmp[2] eq "gene"){
		$gst = $ar_tmp[3];
		$ged = $ar_tmp[4];
		$gid = $ar_tmp2[0];
		print $_."\n";
		$count = 0;
	}elsif($ar_tmp[2] eq "transcript"){
		$count ++;
		#if ($gst == $ar_tmp[3] && $ged == $ar_tmp[4]){
		if ($count == 1){
			print $_."\n";
			$tid = $ar_tmp2[2];
		}else{
			$tid = "null";
		}
	}else{
		if ($ar_tmp2[2] eq $tid){
			print $_."\n";
		}
	}
	
}
close(F);
