#!/usr/bin/perl
#
# treating log file made after DMR generation (another in-house script)
# make DMR-making DMCs into bed formatted (1-3 columns) text file 
#
#
use strict;
use warnings;

my $f_in =shift;

my $DMR_keep = "";
my @last_array = ();
my @methylC_keep = ();
open(F,"$f_in");
while(<F>){
	chomp;
	my @ar_tmp = split(/\t/,$_);
	if (@ar_tmp<=1 && $DMR_keep ne ""){
		$DMR_keep .= $last_array[2]; 
		foreach my $line (@methylC_keep){
			print $line."\t".$DMR_keep."\n";
		}
		@methylC_keep = ();
		$DMR_keep = "";
		next;
	}elsif(@ar_tmp<=1 && $DMR_keep eq ""){next;}
	my $nouse = shift (@ar_tmp);
	if ($DMR_keep){
		push(@methylC_keep,join("\t", @ar_tmp));
	}else{
		my $start = $ar_tmp[1] -1;
		$DMR_keep = "$ar_tmp[0]:$start-";
		push(@methylC_keep,join("\t",@ar_tmp));
	}
	@last_array = @ar_tmp;
}
close(F);
$DMR_keep .= $last_array[2]; 
foreach my $line (@methylC_keep){
	print $line."\t".$DMR_keep."\n";
}
