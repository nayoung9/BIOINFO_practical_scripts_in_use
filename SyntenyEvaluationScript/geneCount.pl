#!/usr/bin/perl
#
#
use strict;
use warnings;

my $f_in = shift;
my $flag = shift;
my $outdir = shift;
my $prefix1 = shift; #ref
my $prefix2 = shift; #tar
my $longchr = shift;


my $gene1 = "/mss2/projects/synteny_builder/Benchmarking/synteny/hg38_panTro5/answer/work_ny/human.ortho.bed";
my $gene2 = "/mss2/projects/synteny_builder/Benchmarking/synteny/hg38_panTro5/answer/work_ny/chimp.ortho.bed";
if ($longchr == 1){
	$gene1= "/mss2/projects/synteny_builder/Benchmarking/synteny/hg38_panTro5/answer/work_ny/human.ortho.longchr.bed";
	$gene2= "/mss2/projects/synteny_builder/Benchmarking/synteny/hg38_panTro5/answer/work_ny/chimp.ortho.longchr.bed";
}

`mkdir -p $outdir`;

#make bed 
if ($flag eq "psl"){
	`cut -f10,12,13 $f_in > $outdir/$prefix2.bed`; 
	`cut -f14,16,17 $f_in > $outdir/$prefix1.bed`; 
}
if ($flag eq "cs"){ #conserved segments
	open(F,"$f_in");
	open(F1,">$outdir/$prefix1.bed");
	open(F2,">$outdir/$prefix2.bed");
	while(<F>){
		chomp;
		if ($_ =~ /^>|^$/){next;}
		if ($_ =~ /^$prefix1.(.+):(\d+)-(\d+) ./){
			print F1 "$1\t$2\t$3\n";
		}
		if ($_ =~ /^$prefix2.(.+):(\d+)-(\d+) ./){
			print F2 "$1\t$2\t$3\n";
		}
	}
	close(F2);
	close(F1);
	close(F);
}
if ($flag eq "v9"){ #new_program, separate run with lev1, lev2 
	open(F,"$f_in");
	open(F1,">$outdir/$prefix1.bed");
	open(F2,">$outdir/$prefix2.bed");
	while(<F>){
		if ($_ =~ /^$|^\t/){next;}
		chomp;
		my @ar = split(/\t/,$_);
		if ($ar[1] =~ /^$prefix1.(.+):(\d+)-(\d+)/){
			print F1 "$1\t$2\t$3\n";
		}
		if ($ar[2] =~ /^$prefix2.(.+):(\d+)-(\d+)/){
			print F2 "$1\t$2\t$3\n";
		}
	}
	close(F2);
	close(F1);
	close(F);

}

## intesect

`bedtools intersect -wao -a $outdir/$prefix1.bed -b $gene1 > $outdir/$prefix1.gene.intersect.txt`;
`bedtools intersect -wao -a $outdir/$prefix2.bed -b $gene2 > $outdir/$prefix2.gene.intersect.txt`;

## collect Genes 

my %hs_Cs1 = ();
my %hs_CsCount1 = ();
my %hs_Cs1Stat = ();
open (F1,"$outdir/$prefix1.gene.intersect.txt");
while(<F1>){
	my @ar_tmp = split(/\t/,$_);
	my $Csid = "$ar_tmp[0]\t$ar_tmp[1]\t$ar_tmp[2]";
	my $genlen = $ar_tmp[5] - $ar_tmp[4];
	my $ovlen = $ar_tmp[7];
	if (!exists ($hs_CsCount1{$Csid}{"cut"})){
		$hs_CsCount1{$Csid}{"cut"} = 0;
		$hs_CsCount1{$Csid}{"contain"} = 0;
		$hs_Cs1Stat{$Csid}{$ar_tmp[6]} = "";
		$hs_Cs1{$Csid} = "";
	}
	if ($ovlen !=  $genlen ){
		$hs_CsCount1{$Csid}{"cut"} ++;
		$hs_Cs1Stat{$Csid}{$ar_tmp[6]} = "cut";
		$hs_Cs1{$Csid} .= "$ar_tmp[6];";
	}else{
		$hs_CsCount1{$Csid}{"contain"} ++;	
		$hs_Cs1Stat{$Csid}{$ar_tmp[6]} = "contain";
		$hs_Cs1{$Csid} .= "$ar_tmp[6];";
	}
}
close(F1);


my %hs_Cs2 = ();
my %hs_CsCount2 = ();
my %hs_Cs2Stat = ();
open (F2,"$outdir/$prefix2.gene.intersect.txt");
while(<F2>){
	my @ar_tmp = split(/\t/,$_);
	my $Csid = "$ar_tmp[0]\t$ar_tmp[1]\t$ar_tmp[2]";
	my $genlen = $ar_tmp[5] - $ar_tmp[4];
	my $ovlen = $ar_tmp[7];
	if (!exists ($hs_CsCount2{$Csid}{"cut"})){
		$hs_CsCount2{$Csid}{"cut"} = 0;
		$hs_CsCount2{$Csid}{"contain"} = 0;
		$hs_Cs2Stat{$Csid}{$ar_tmp[6]} = "";
		$hs_Cs2{$Csid} = "";
	}
	if ($ovlen !=  $genlen ){
		$hs_CsCount2{$Csid}{"cut"} ++;
		$hs_Cs2Stat{$Csid}{$ar_tmp[6]} = "cut";
		$hs_Cs2{$Csid} .= "$ar_tmp[6];";
	}else{
		$hs_CsCount2{$Csid}{"contain"} ++;	
		$hs_Cs2Stat{$Csid}{$ar_tmp[6]} = "contain";
		$hs_Cs2{$Csid} .= "$ar_tmp[6];";
	}
}
close(F2);

## get orthopair 
my %hs_ortho = ();
open (FO,"/mss2/projects/synteny_builder/Benchmarking/synteny/hg38_panTro5/answer/work_ny/all.orthologous.pair");
while(<FO>){
	chomp;
	my @ar_tmp = split(/\t/,$_);
	$hs_ortho{$ar_tmp[3]}{$ar_tmp[7]} = 1;
	$hs_ortho{$ar_tmp[7]}{$ar_tmp[3]} = 1;
}
close(FO);


## collect alignment information
open (F1,"$outdir/$prefix1.bed");
open (F2,"$outdir/$prefix2.bed");
open (F3,">$outdir/RawGeneCount.txt");
open (F4,">$outdir/OrthoGeneCount.txt");
open (F5,">$outdir/Combination.txt");
open (F6,">$outdir/allCounts.txt");
while(<F1>){
	chomp;
	my $Cs1 = $_;
	my $Cs2 = <F2>;
	chomp $Cs2;
	## log
	print STDERR "$Cs1\t$Cs2\n";
	print STDERR "\t$hs_Cs1{$Cs1}\n";
	print STDERR "\t$hs_Cs2{$Cs2}\n";

	## raw count
	my $raw1all = $hs_CsCount1{$Cs1}{'cut'} + $hs_CsCount1{$Cs1}{'contain'};
	my $raw2all = $hs_CsCount2{$Cs2}{'cut'} + $hs_CsCount2{$Cs2}{'contain'};
	print F3 "$Cs1\t$Cs2\t$hs_CsCount1{$Cs1}{'cut'}\t$hs_CsCount1{$Cs1}{'contain'}\t$raw1all\t$hs_CsCount2{$Cs2}{'cut'}\t$hs_CsCount2{$Cs2}{'contain'}\t$raw2all\n";
	
	##ortho count 
	my @ar_genes1 = split(/;/,$hs_Cs1{$Cs1});
	my @ar_genes2 = split(/;/,$hs_Cs2{$Cs2});
	my $ortho1 = 0;
	my $ortho1cut = 0;
	my $ortho1contain = 0;
	my $ortho2 = 0;
	my $ortho2cut = 0;
	my $ortho2contain = 0;
	foreach my $g1 (@ar_genes1){
		foreach my $g2 (@ar_genes2){
			if (exists($hs_ortho{$g1}{$g2})){
				$ortho1++;
				if ($hs_Cs1Stat{$Cs1}{$g1} eq "cut"){
					$ortho1cut++;
				}else{
					$ortho1contain++;
				}
				last;
			}
		}
	}
	foreach my $g2 (@ar_genes2){
		foreach my $g1 (@ar_genes1){
			if (exists($hs_ortho{$g2}{$g1})){
				$ortho2++;
				if ($hs_Cs2Stat{$Cs2}{$g2} eq "cut"){
					$ortho2cut++;
				}else{
					$ortho2contain++;
				}
				last;
			}
		}
	}
	print F4 "$Cs1\t$Cs2\t$ortho1cut\t$ortho1contain\t$ortho1\t$ortho2cut\t$ortho2contain\t$ortho2\n";

	##combination + combination rate
	my $all_comb = 0;
	my $exists_comb = 0;
	my %hs_counted = ();
	foreach my $g1 (@ar_genes1){
		foreach my $orthog2 (keys %{$hs_ortho{$g1}}){
			$hs_counted{$g1}{$orthog2} = 1;
			$all_comb ++;	
		}
	}
	foreach my $g2 (@ar_genes2){
		foreach my $orthog1 (keys %{$hs_ortho{$g2}}){
			if (exists($hs_counted{$orthog1}{$g2})){
				next;
			}else{
				$all_comb++;
			}
		}
	}
	foreach my $g1 (@ar_genes1){
		foreach my $g2 (@ar_genes2){
			if (exists($hs_counted{$g1}{$g2})){
				$exists_comb ++;
			}
		}
	}
	my $ratio = 0;
	if ($all_comb != 0){
		$ratio = $exists_comb/$all_comb;
	}else{
		$ratio = "-";
	}
	print F5 "$Cs1\t$Cs2\t$exists_comb\t$all_comb\t$ratio\n";

	#all
	print F6 "$Cs1\t$Cs2\t$hs_CsCount1{$Cs1}{'cut'}\t$hs_CsCount1{$Cs1}{'contain'}\t$raw1all\t$hs_CsCount2{$Cs2}{'cut'}\t$hs_CsCount2{$Cs2}{'contain'}\t$raw2all\t$ortho1cut\t$ortho1contain\t$ortho1\t$ortho2cut\t$ortho2contain\t$ortho2\t$exists_comb\t$all_comb\t$ratio\n";

}
close(F6);
close(F5);
close(F4);
close(F3);
close(F2);
close(F1);
