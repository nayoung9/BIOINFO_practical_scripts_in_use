#!/usr/bin/perl
#
#
use strict;
use warnings;
use Cwd;
use Net::FTP::File;

#my $download_path = "/mss_ds/project/denovo2_pipe/DATA/GENOME/";
my $download_path = "./";
my $query = join(" ",@ARGV);
my $grepquery = "\"".$query."\"";

my $host = "ftp.ncbi.nlm.nih.gov";
my $ftp = Net::FTP->new($host, Timeout=>3600) || die;
$ftp->login("anonymous",'-') || die;
$ftp->binary();
$ftp->passive(1);
my $subDir = '/genomes/refseq/';
my $result = `grep $grepquery ./assembly_summary_refseq.txt`;
my @ar_results = split(/\n/,$result);
if(@ar_results == 0){print STDERR "No exact matches\n"; return;}
my $newpath = "";
my @ar_line = ();
if(@ar_results != 1){
foreach my $line (@ar_results){
	@ar_line = split(/\t/,$line);
	if ($ar_line[7] eq "$query"){  ## need more specific and considerate 
		$newpath = $ar_line[19];
		last;
	}
}
}else{
	@ar_line = split(/\t/,$ar_results[0]);
	$newpath = $ar_line[19];
}
my $targetpath = "";
if ($newpath =~ /.+$host(.+)/){
	$targetpath = $1;
}
$ftp->cwd($targetpath); 
my $pwd = $ftp->pwd();
my @ar_path = split(/\//,$targetpath);
my $query_id = $ar_path[$#ar_path];
my $f_fna = "$query_id\_genomic.fna.gz";
my $f_gff = "$query_id\_genomic.gff.gz";
my $f_rep = "$query_id\_assembly_report.txt";
my $f_md5 = "md5checksums.txt";

my $spc_name = $ar_line[7];
$spc_name =~ s/ /-/g;

`mkdir -p  $download_path/$spc_name/$ar_line[15]/`;
chdir "$download_path/$spc_name/$ar_line[15]/";

$ftp->get($f_md5);
foreach my $thisfile  ($f_fna, $f_gff, $f_rep){
	my $size = $ftp->size($thisfile);
	if ($size != 0 ){
		my $valid = 0;
		while($valid==0){
			$ftp->get($thisfile);
			my $md5 = `md5sum $thisfile | cut -f1 -d" " `;
			my $orig = `grep $thisfile md5checksums.txt | cut -f1 -d" "`;
			if ($md5 eq $orig){$valid = 1;}
		}
	}else{
		print STDERR "there is no $thisfile\n"
	}
}
`rm -rf md5checksums.txt`;
$ftp->quit;
