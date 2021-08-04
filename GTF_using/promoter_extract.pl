#!/usr/bin/perl
#
#
use strict;
use warnings;
my $f_gff = shift; ## only exons 
my $f_size = shift ;

my %hs_size = ();
open(FS,"$f_size");
while(<FS>){
	chomp;
	my ($chr, $size) = split(/\s+/,$_); 
	$hs_size{$chr} = $size;
}
close(FS);


open(F,"$f_gff");
while(<F>){
	chomp;
	my @ar_tmp = split(/\t/,$_);
	my @ar_desc = split(/; /, $ar_tmp[8]);
	my $chr = $ar_tmp[0];
	my $strand = $ar_tmp[6];
	my $start = $ar_tmp[3];
	my $end = $ar_tmp[4];
	my $gid = "";
	my $tid = "";
	my $enum = "";
	foreach my $val (@ar_desc){
		if ($val =~ /^gene_id "(.+)"/){
			$gid = $1;
		}elsif($val =~ /^transcript_id "(.+)"/){
			$tid = $1;
		}
	}
	if ($strand eq "+"){
		$end = $start -1;
		$start = $end - 1000+1;
	}else{
		#strand == "-"
		$start = $end+1;
		$end = $start + 1000 -1;
	}
	##VAL
	if ($start < 0 || $end < 0 ){
		print STDERR "NO PMT : $_\n";
		next;
	}
	if ($start > $hs_size{$chr} || $end > $hs_size{$chr}){
		print STDERR "NO PMT : $_\n";
		next;
	}
	print "$ar_tmp[0]\t$ar_tmp[1]\tpromoter\t$start\t$end\t.\t$strand\t.\tgene_id \"$gid\"; transcript_id \"$tid\"\n"; 
}
close(F);

