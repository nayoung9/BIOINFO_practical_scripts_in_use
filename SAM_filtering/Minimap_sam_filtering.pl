#!/usr/bin/perl
#
#
# FILTER SAM from Minimap (longread - single read) 
# recommend that input should be unsorted (query sorted): get first results when all conditions are exactly same 
# 1st : filter unmapped results
# 2nd : Select longer alignment 
# 3rd : less gap + mismatch counts 
# 
use strict;
use warnings;

my %hs_keep = (); #id - whole_line
my %hs_length = (); #id - length 
my %hs_qual = (); #id - mismatch+gap count
my $f_in = shift;
open(F,"$f_in");
while(<F>){
	chomp;
	if ($_ =~ /^@/){next;}
	my @ar_tmp = split(/\t/,$_);
	my $id = $ar_tmp[0];
	my $cigar = $ar_tmp[5];
	my $NM = $ar_tmp[11];
	my @ar_cigar_num = split(/\D/,$cigar);
	my @ar_cigar_char = split(/\d+/,$cigar);
	
	if ($ar_tmp[1] == 4){next;} #unmapped
	my $len = 0;
	for (my $i = 0 ; $i <= $#ar_cigar_num ; $i ++){
		my $idx = $i+1;
		if ($ar_cigar_char[$idx] =~/M|I|S|=|X/){
			$len += $ar_cigar_num[$i];
		}
	}
	my $mn = 0;
	if ($NM =~ /NM:i:(\d+)/){
		$mn = $1
	}else{
		print STDERR "check it out\n"; 
		print STDERR $id."\n";
		exit;
	}
	if (!exists($hs_keep{$id})){
		$hs_keep{$id} = $_;
		$hs_length{$id} = $len;
		$hs_qual{$id} = $mn;
	}else{
		if($hs_length{$id} < $len){
			$hs_length{$id} = $len;
			$hs_qual{$id} = $mn;
			$hs_keep{$id} = $_;
		}elsif($hs_length{$id} == $len){
			if ($hs_qual{$id} > $mn){
				$hs_qual{$id} = $mn;
				$hs_keep{$id} = $_;
			}
		}
	}
}
close(F);

foreach my $id (keys %hs_keep){
	print $hs_keep{$id}."\n";
}
