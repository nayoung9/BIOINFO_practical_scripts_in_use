#!/usr/bin/perl
#
#
use strict;
use warnings;

my $f_in = shift;   #any bed formatted ( first column is chromosome)
my $chr_info = shift; # chromosome notation information (first column : new / second column : existing data)
#

#input bed (rm.out -> bed converted forexample / any bed formats are okay that has first column as chromosome )
#NC_060925.1	1	2705	(ACCCTA)n	2590	+	2.900	0.600	1.000	(248384623)	Simple_repeat	1	2693	(0)	1
#NC_060925.1	1	2705	(ACCCTA)n	2590	+	2.900	0.600	1.000	(248384623)	Simple_repeat	1	

#chr_info file 
##Chromosome	Accession.version
#1	NC_060925.1
#2	NC_060926.1
#3	NC_060927.1
#4	NC_060928.1
#5	NC_060929.1




my %hs_chrinfo = ();
open(F,"$chr_info");
while(<F>){
	chomp;
	my ($new, $find) = split(/\s+/,$_);
	$hs_chrinfo{$find} = $new;
}
close(F);

open(F,"$f_in");
while(<F>){
	chomp;
	my @ar_tmp = split(/\t/,$_);
	my $find = shift(@ar_tmp);
	my $new = $hs_chrinfo{$find};
	print $new."\t".join("\t",@ar_tmp)."\n";
}
close(F);
