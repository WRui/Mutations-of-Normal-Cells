#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;

#--------------------help and option guide----------------------#
my $usage=<<USAGE;
Usage
	perl $0
	indir	<str: the input dir of the samples>
	outdir	<str: the output dir of the samples>
	sample	<str: sample names>

USAGE

my ($indir,$outdir,$sample,$help);

GetOptions(
	"indir=s"=>\$indir,
	"outdir=s"=>\$outdir,
	"sample=s"=>\$sample,
	"h:s"=>\$help,
);

die $usage if $help;
die $usage unless $indir && $outdir && $sample;
#--------------------help and option guide----------------------#


#-trim && create the dir if not exists
$indir = trim_slash($indir);
$outdir = trim_slash($outdir);
`mkdir -p $outdir/$sample` unless (-d "$outdir/$sample");

#-the common global variables
#my $alt,$ref,%Mutant;


#------------------------Processing begin------------------------------------------#
#chomp(my $file = `ls $indir/$sample/*.HaplotypeCaller.variants_result.ann_dbSNP_ClinVar.vcf`);
chomp(my $file = `ls $indir/$sample/*.HaplotypeCaller.ann.vcf`);

#-open the input file
open (IN,"<", $file) or die $!;

#-open the output file
open (OUT, ">","$outdir/$sample/$sample.ATCG_MutantType.txt") or die $!;

my %Mutant;

while ( my $line = <IN> ){
	next if $line =~ /^#/;
	chomp ($line);

	my @columns = split("\t",$line);
#	my %Mutant;
	my $ref = $columns[3];
	my $alt = $columns[4];

	if(length($ref)==1 && length($alt)==1){
		my $MutType = $ref.'_'.$alt;
		if (exists $Mutant{$MutType}){
			$Mutant{$MutType} = $Mutant{$MutType}+1;
		}else{
			$Mutant{$MutType} = 1;
		}

		if(exists $Mutant{"All"}){
			$Mutant{"All"} = $Mutant{"All"} +1;
		}else{
			$Mutant{"All"} = 1;
		}
	}else{
		if (exists $Mutant{"Other"}){
			$Mutant{"Other"} = $Mutant{"Other"} +1;
		}else{
			$Mutant{"Other"} = 1;
		}
		# cal the total number of mutant sites
		if(exists $Mutant{"All"}){
            $Mutant{"All"} = $Mutant{"All"} +1;
        }else{
            $Mutant{"All"} = 1;
        }

	}

}


foreach my $type (sort keys %Mutant){
	print OUT "$type\t$Mutant{$type}\n";
}


#-------------------function section----------------------------#

#-dir trimming

sub trim_slash {
    my($dir) = @_;
    ($dir =~/\/$/) ? ($dir =~ s/\/$//) : ($dir = $dir) ;
}


