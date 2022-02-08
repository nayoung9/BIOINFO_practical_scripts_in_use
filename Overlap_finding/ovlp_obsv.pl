#!/usr/bin/perl
use strict;
use warnings;
###
#	Observing overlapped region (no overlap on ref)
#	read .axt to find overlap
#	read .base to ovserve overlap region
###
#Finding overlap and return overlapped region
sub FindOvl{
	my ($l, $r, $st, $ed) = @_;
	if ($l <= $ed && $r >= $st){
		my @tmp_ar = ($l, $r, $st, $ed);
		@tmp_ar = sort{$a<=>$b}(@tmp_ar);
		return $tmp_ar[1]." ".$tmp_ar[2];
	}else{
		return 0;
	}
}

###

my $f_axt = shift;
my %hs_axt = ();
my %hs_tar = ();
my @ar_ovl = ();
open(FA,"$f_axt");
while(<FA>){
	if ($_ !~ /^\d/){next;}
	chomp;
	my ($id, $ref, $rst, $red, $tar, $tst, $ted, $ori, $score) = split(/\s+/,$_);
	if (exists($hs_axt{$tar})){
		foreach my $this_aln (split(/\n/,$hs_axt{$tar})){
			my ($this_id, $this_tst, $this_ted) = split(/ /,$this_aln);	
			my $ovlchk = FindOvl($this_tst, $this_ted, $tst, $ted);
			if ($ovlchk){
				push(@ar_ovl,$this_id." ".$id." ".$tar." ".$ovlchk);
			}
		}
	}
	$hs_axt{$tar} .= $id." ".$tst." ".$ted."\n";
	$hs_tar{$id} = $tst." ".$ted
}
close(FA);

my $f_base = shift;
foreach my $ovl (@ar_ovl){
	my ($id1, $id2, $tar,$ovlst, $ovled ) = split(/ /,$ovl);
	print STDOUT ">$tar\t$id1\t$id2\t$ovlst\t$ovled\n";
	my $chk = 0;
	my $ovlregion = 0;
	my $ref_start = 0;
	my %hs_score = ();
	my ($strand, $cur_id, $cur_ref) = "";
	open(FB,"$f_base");
	while(<FB>){
		chomp;
		if ($_ =~ /^>($id1|$id2) /){
			$chk = 1;
			$cur_id = $1;
			my @tmp_curaln = split(/ /,$_);
			$strand = $tmp_curaln[7];
			$cur_ref = $tmp_curaln[1];
			%hs_score = ();
			next;
		}elsif ($_ =~ /^>/){
			$chk = 0;
		}
		if ($chk != 0){
			my @base_ar = split(/\t/,$_);
			my $position = $base_ar[5];
			if ($position !~ /\d+/){
				if($ovlregion ==1){
					$hs_score{$base_ar[7]} ++;
				}
				next;
			}
			if($strand eq "-"){
				my ($tst, $ted) = split(/ /,$hs_tar{$cur_id});
				$position = $tst + $ted - $position
			}
			if ($position >= $ovlst && $position <= $ovled){
				$ovlregion = 1;
				$hs_score{$base_ar[7]} ++;		
				if (($strand eq "+" && $position == $ovlst)||($strand eq "-" && $position == $ovled) ){
					$ref_start = $base_ar[2];
				}
				if (($strand eq "+" && $position == $ovled)||($strand eq "-" && $position == $ovlst) ){
					foreach my $key ("MATCH","MISMATCH","TARGAP","REFGAP"){
						if (!exists($hs_score{$key})){
							$hs_score{$key} = "0";
						}
					}
					my $reflen = $hs_score{"MATCH"} + $hs_score{"MISMATCH"} + $hs_score{"TARGAP"};
					print STDOUT "\t$cur_id\t$cur_ref\t$ref_start\t$base_ar[2]\t$reflen\tM:$hs_score{MATCH}\tMM:$hs_score{MISMATCH}\tTG:$hs_score{TARGAP}\tRG:$hs_score{REFGAP}\n";
				}
			}
		}
	}
	close(FB);
}

