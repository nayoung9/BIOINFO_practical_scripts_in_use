#!/usr/bin/perl
#

use strict;
use warnings;

my $f_in = shift;

open (F,"$f_in");
while(<F>){
	chomp;
	if ($_ =~ /^>/){
		print $_."\n";
		next;
	}else{
		my $new = uc($_);
		print $new."\n";
	}
}
close(F);
