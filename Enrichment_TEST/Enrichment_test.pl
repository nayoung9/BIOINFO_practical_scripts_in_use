#!/usr/bin/perl 


use strict;
use warnings;
use Cwd 'abs_path';
use File::Basename;
use Sort::Key::Natural 'natsort';
use FindBin '$Bin';

my $f_query = shift; # query target list #ID
my $sig_level = shift;
my $dir_out = abs_path(shift); #output directory 

my $qvalue_R = $Bin."/qvalue.R";
my $pvalue_R = $Bin."/pvalue.R";

my $reference_targetCharList = shift; #target-character list (Chr-start-end-ID-Name-CHARlist(separated with ";", example in /mss3/RDA_Phase2/evolution/KNP/data/pigs_target/target.tsv)
my $reference_charGeneList = shift; #character-target list #CHAR-targetlist(separated with ";", example in /mss3/RDA_Phase2/evolution/KNP/data/pigs_target/GO_target.txt)
my $f_write = $dir_out."/sorted_GO_pv_tmp.txt";
my $f_CHARannot = $dir_out."/CHAR_annot.txt";

#Read query targets 
#use first column as target id from query input targetlist file 
my %hs_target = ();
open(F,"$f_query");
while(<F>){
    if ($_ =~ /^#/){next;}
    chomp;
    my @tmp_ar = split(/\t/,$_);
    if (!exists($hs_target{$tmp_ar[0]})){
        $hs_target{$tmp_ar[0]} = 1;# %{ID} = 1 
    }else{
        next;
    }
}
close(F);

my $reftargetnum = 0;
my $querytargetnum = 0;

#modify query input 
open(FTMP,">$f_CHARannot")or die "$!\n";
print FTMP "#ID\tCHAR\n";
open(FG,"$reference_targetCharList");
while(<FG>){
    if ($_ =~ /^#/){next;}
    chomp;
    my @tmp_target = split(/\t/,$_);
    $reftargetnum ++;
    if ($hs_target{$tmp_target[3]}){
        print FTMP "$tmp_target[3]\t$tmp_target[5]\n";
        $querytargetnum ++;
    }else{
        next;
    }
}
close(FG);
close(FTMP);


#query set 
my %hs_queryGO = (); #only run with character terms have annotation in query target list 
open(FQ,"$f_CHARannot");
while(<FQ>){
    if ($_ =~ /^#/){next;}
    chomp;
    my ($id,$GOs) = split(/\t/,$_);
    foreach my $GO (split(/;/,$GOs)){
        if(!exists $hs_queryGO{$GO}){
            $hs_queryGO{$GO} = 1;
        } else {
            $hs_queryGO{$GO}++;
        }
    }
}
close(FQ);



#TTEST
my $N = $reftargetnum;  #population
my $n;  #ref targets have this GO
my $m = $querytargetnum; #query target #
my $k;  #query targets have this GO
my @pval;
my @GO = ();
open(FR,"$reference_charGeneList");
open(FP,">$dir_out/arg_tmp.txt");
while(<FR>){
    if($_ =~ /^#/){next;}
    chomp;
    my($thisGO,$targets) = split(/\t/,$_);
    my @ar_target = split(/;/,$targets);
    my $n = scalar @ar_target;
    my $k ;
    if(exists($hs_queryGO{$thisGO})){
        $k=$hs_queryGO{$thisGO};
    }else{
        $k=0
    }
    print FP "$thisGO,$k,$m,$n,$N\n";
}
close(FP);
close(FR);

#calculate qvalue 
`$pvalue_R $dir_out/arg_tmp.txt > $dir_out/pv_GO_tmp.txt`;
open(FPG,"$dir_out/pv_GO_tmp.txt");
while(<FPG>){
    chomp;
    push(@pval,$_);
}
close(FPG);
open(FOUT,">$f_write");
foreach my $this(sortpair(@pval)){
    my ($pv,$GO) = split(/\t/,$this);
    print FOUT $GO,"\t".$pv."\n";
}
close(FOUT);
`awk '{print\$2}' $f_write > $dir_out/pv_tmp.txt`;
`$qvalue_R  $dir_out/pv_tmp.txt > $dir_out/qv_tmp.txt`;
`paste $f_write $dir_out/qv_tmp.txt > $dir_out/result.txt`;

open(W,">$dir_out/significant_go.txt");
open(F,"$dir_out/result.txt");
while(<F>){
    chomp;
    my @arr = split(/\s+/);
    if($arr[2] > $sig_level){next;}
    print W  "$_\n";
}
close(F);
close(W);

sub sortpair{
    #sort pair (pvalue - GOacc)
    my @ar_pair = @_;
    my %tmp_hs = ();
    my @return_pair = ();
    foreach (@ar_pair){
        chomp $_;
        my ($pval,$goacc) = split(/\t/,$_);
        $tmp_hs{$pval}{$goacc} = 0;
    }
    foreach my $pv (sort{$a<=>$b} keys %tmp_hs){
        foreach my $goo (natsort(keys %{$tmp_hs{$pv}})){
            push(@return_pair,"$pv\t$goo");
        }
    }
    return @return_pair;
}
          
