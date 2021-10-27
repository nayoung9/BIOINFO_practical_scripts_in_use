#!/usr/bin/perl
#
#
use strict;
use warnings; 
#add addi in front of the fasta name >[addi]#### 

my $f_in = shift;
my $addi = shift;

open(F,"$f_in");
while(<F>){
        chomp;
        if ($_ =~ /^>(.+)$/){
                print ">$addi$1\n";
        }else{
                print $_."\n";
        }
}
close(F);
