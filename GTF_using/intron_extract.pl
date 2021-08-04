#!/usr/bin/perl
#
# all exon -> split exon_1 and rest exons
# make intron rows -> intron_1 and rest introns 
#
use strict;
use warnings;
my $f_gff = shift; ## only exons 

my %hs_exonsave = ( );

open(F,"$f_gff");
while(<F>){
	chomp;
	my @ar_tmp = split(/\t/,$_);
	my @ar_desc = split(/; /, $ar_tmp[8]);
	my $gid = "";
	my $tid = "";
	my $enum = "";
	foreach my $val (@ar_desc){
		if ($val =~ /^gene_id "(.+)"/){
			$gid = $1;
		}elsif($val =~ /^transcript_id "(.+)"/){
			$tid = $1;
		}elsif ($val =~ /^exon_number "(.+)"/){
			$enum = $1;
		}
	}
	$hs_exonsave{$gid}{$tid}{$enum} = $_;
	#print "$gid $tid $enum\n";
	if ($enum ==1){
		$ar_tmp[2] = "exon_1"
	}
	my $print_orig = join("\t",@ar_tmp);
	print $print_orig."\n";
}
close(F);

##############################################################


my $start = 0;
my $end = 0;

for my $gene (keys %hs_exonsave){
	for my $transcript (keys %{$hs_exonsave{$gene}}){
		my @ar_tmp = split(/\t/,$hs_exonsave{$gene}{$transcript}{1});
		my $strand = $ar_tmp[6];
		$start = 0;
		$end = 0;
		if ($strand eq "+"){
			$start = $ar_tmp[4];
		}else{
			$end = $ar_tmp[3];
		}
		my $intron_num = 1;
		for my $number (sort { $a <=> $b } keys %{$hs_exonsave{$gene}{$transcript}}){
			if ($number == 1){next;}
        	my @ar_tmp = split(/\t/,$hs_exonsave{$gene}{$transcript}{$number});
			if ($strand eq "+"){
				$end = $ar_tmp[3];
			}else{
				$start = $ar_tmp[4];
			}
			if ($start != 0 && $end != 0){
				if ($intron_num == 1){
					print "$ar_tmp[0]\t$ar_tmp[1]\tintron_1\t$start\t$end\t.\t$strand\t.\tgene_id \"$gene\"; transcript_id \"$transcript\"; intron_number \"$intron_num\";\n";
				}else{
					print "$ar_tmp[0]\t$ar_tmp[1]\tintron\t$start\t$end\t.\t$strand\t.\tgene_id \"$gene\"; transcript_id \"$transcript\"; intron_number \"$intron_num\";\n";
				}
				if ($strand eq "+"){
					$start = $ar_tmp[4];
					$end = 0;
				}else{
					$end = $ar_tmp[3];
					$start = 0;
				}
			}
			$intron_num++;
		}
	}
}

