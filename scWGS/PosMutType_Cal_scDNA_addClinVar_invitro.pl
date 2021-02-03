#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;

#--------------------help and option guide----------------------#
my $usage= <<USAGE;
Usage 
	perl $0
	indir	<str:the input dir of the samples>
	outdir	<str:the output dir of the samples>
	sample	<str:sample>
	depth	<int:minimum sequencing depth>

USAGE

my ($indir,$outdir,$sample,$depth,$help);

GetOptions(
	"indir=s"=>\$indir,
	"outdir=s"=>\$outdir,
	"sample=s"=>\$sample,
	"depth=i"=>\$depth,
	"h:s"=>\$help,
);

die $usage if $help;
die $usage unless $indir && $outdir && $sample;
#--------------------help and option guide----------------------#

#-default parameters value
$depth ||= 2;


#-trim && create the dir if not exists

$indir = trim_slash($indir);
$outdir = trim_slash($outdir);
`mkdir -p $outdir/$sample` unless(-d "$outdir/$sample");

#-the common global variables
my($homo_ref,$homo_alt,$heter,$ref_allele,$alt_allele,$alt_ratio,$pass_cell,$ref_allele_p,$alt_allele_p,$alt_ratio_p) = (0) x 10;



#------------------------Processing begin------------------------------------------#

#-get the input file
#chomp( my $file = `ls $indir/$sample/*.variants_result.ann.vcf`); ##scDNA-Seq
chomp( my $file = `ls $indir/$sample/*.variants_result.Exon.ann_dbSNP_ClinVar.vcf`); ##scDNA-Seq only print WES region 

#-open the input file
open (IN,"<", $file) or die $!;

#-open the output file
open (OUT, ">","$outdir/$sample/$sample.${depth}X_Exon_ClinVar_dbSNP_ann_invitro.txt") or die $!;

#print OUT "#sumRef\tsumAlt\tReadRatio\tnHomo\tnHeter\tnAlt\tCellRatio\tAlt_str\tRef_str\tsumRef_Pass\tsumAlt_Pass\tReadRatio_Pass\tnHomo_Pass\tnHeter_Pass\tnAlt_Pass\tCellRatio_Pass\tAlt_str_Pass\tRef_str_Pass\n";

while ( my $line = <IN> ){
	next if $line =~ /^#/;
	chomp ($line);

	my @columns = split("\t",$line);
	
	my $chr = $columns[0];
	my $pos = $columns[1];
	my $ref = $columns[3];
	my $alt = $columns[4];
	my $last_index = $#columns;
#	my @cells = @columns[9..$last_index]; #scDNA
#	my @cells = @columns[201..392]; # CRC19
	my @cells = @columns[681..1832]; # CRC16
	
	my @Results = GT_stats(@cells);
	
	my $SNP_info = join("\t",@columns[0..7]); # scDNA

	my @SNP_info_detail = split /\|/,$columns[7];

    my $MuType = $SNP_info_detail[1];
    my $Effect = $SNP_info_detail[2];
    my $Gene = $SNP_info_detail[3];
    my $Coding = $SNP_info_detail[7];
    my $DNA = defined($SNP_info_detail[9]) ? $SNP_info_detail[9] : "-";
    my $Protein = defined($SNP_info_detail[10]) ? $SNP_info_detail[10] : "-";


	my $CLNSIG;
	if ($columns[7] =~ /CLNSIG=(\w+);/){
		$CLNSIG = $1;
	}else{
		$CLNSIG = '-';
	}
	my $SAO;
	if ($columns[7] =~ /SAO=(\d);/)	{
		$SAO = $1;
	}else{
		$SAO = '-';
	}

	my $ORIGIN;
	if ($columns[7] =~ /ORIGIN=(\d+);/){
		$ORIGIN = $1;
	}else{
		$ORIGIN = '-';
	}

	my $GT_AD_info = join("\t",@Results);
#	print OUT "$SNP_info\t$CLNSIG\t$SAO\t$ORIGIN\t$GT_AD_info\n";
	print OUT "$SNP_info\t$MuType\t$Effect\t$Gene\t$Coding\t$DNA\t$Protein\t$CLNSIG\t$SAO\t$ORIGIN\t$GT_AD_info\n";
		
}

#-------------------function section----------------------------#

#-dir trimming

sub trim_slash {
	my($dir) = @_;
	($dir =~/\/$/) ? ($dir =~ s/\/$//) : ($dir = $dir) ;
}

#-calculate the cell number with 0|0, 0|1, 1|1

sub GT_stats {

	my @elements = @_;
	#https://www.oreilly.com/library/view/perl-cookbook/1565922433/ch04s14.html
	
	my @homoRef = grep { /^0\/0/ } @elements;
	my @heter = grep { /^0\/1/ } @elements;
	my @homoAlt = grep { /^1\/1/ } @elements;

	my $nHomo = @homoRef; # number of cells GT is 0|0
	my $nHeter = @heter; # number of cells GT is 0|1
	my $nAlt = @homoAlt; # number of cells GT is 1|1


	my ($sumRef,$sumAlt,$sumRef_pass,$sumAlt_pass,$nPassHomo,$nPassHeter,$nPassAlt) = (0) x 7;
	
	my @Ref;
	my @Ref_depth;
	my @Alt;
	my @Alt_depth;
	
	
	#-0|0, DP all from ref allele
	foreach(@homoRef) {
		my @tmp_ref_array = split(":",$_);
		my $tmp_ref = int($tmp_ref_array[2]);
		$sumRef += $tmp_ref; # DP of ref allele;
		push(@Ref,$tmp_ref);
		push(@Alt,'-'); # add by WR
		if ($tmp_ref > $depth){
			push(@Ref_depth,$tmp_ref);
			push(@Alt_depth,'-');
			$sumRef_pass += $tmp_ref;
			$nPassHomo++;
		}
	}

	#-1|1, DP all from alt allele
	foreach(@homoAlt) {
		my @tmp_alt_array = split(":",$_);
		my $tmp_alt = int($tmp_alt_array[2]);
		push(@Alt,$tmp_alt);
		push(@Ref,"-"); ## add by WR
		$sumAlt += $tmp_alt;
		if ($tmp_alt > $depth) {
			push(@Alt_depth,$tmp_alt);
			push(@Ref_depth,'-');
			$sumAlt_pass += $tmp_alt;
			$nPassAlt++;
		}
	}
	
	#-0|1, AD: ref + alt allele
	foreach(@heter) {
		my @tmp_heter_array = split(":",$_);
		my $AD = $tmp_heter_array[1];
		my $DP = int($tmp_heter_array[2]);
		my ($tmp_ref2,$tmp_alt2) = split(",",$AD);
		$sumRef += int($tmp_ref2);
		$sumAlt += int($tmp_alt2);

		push(@Alt,int($tmp_alt2));
		push(@Ref,int($tmp_ref2));

		if($DP>$depth){
			push(@Alt_depth,$tmp_alt2);
			push(@Ref_depth,$tmp_ref2);
			$sumAlt_pass += $tmp_alt2;
			$sumRef_pass += $tmp_ref2;
			$nPassHeter++;
		}
		
	}
	
#	my $Alt_str = join(",",@Alt);
#	my $Ref_str = join(",",@Ref);
#	my $Alt_depth_str = join(",",@Alt_depth);
#	my $Ref_depth_str =join(",",@Ref_depth);
    my $Alt_str = length(join(",",@Alt)) == 0 ? "NA" : join(",",@Alt);
    my $Ref_str = length(join(",",@Ref)) == 0 ? "NA" : join(",",@Ref);
    my $Alt_depth_str = length(join(",",@Alt_depth)) == 0 ? "NA" : join(",",@Alt_depth);
    my $Ref_depth_str = length(join(",",@Ref_depth)) == 0 ? "NA" : join(",",@Ref_depth);

	
	my $cell_ratio = "NA";
	if($nHomo>0 || $nHeter>0 || $nAlt >0) {
		$cell_ratio = sprintf("%.3f",(0.5*$nHeter+$nAlt)/($nHomo+$nHeter+$nAlt));
	}
#	$cell_ratio = sprintf("%.3f",(0.5*$nHeter+$nAlt)/($nHomo+$nHeter+$nAlt+0.001));

	my $cell_ratio_pass = "NA";
	if ($nPassAlt>0 || $nPassHeter>0 || $nPassHomo>0){
		 $cell_ratio_pass = sprintf("%.3f",($nPassAlt + 0.5* $nPassHeter) / ($nPassAlt + $nPassHeter + $nPassHomo));
	}

	my $read_ratio = "NA";
	
	if ($sumRef >0 || $sumAlt>0 ){
		$read_ratio = sprintf("%.3f",$sumAlt / ($sumRef + $sumAlt));
	}
#	my $read_ratio = sprintf("%.3f",$sumAlt / ($sumRef + $sumAlt));
	
	my $read_ratio_pass = "NA";
	if ( $sumAlt_pass > 0 || $sumRef_pass > 0) {
		$read_ratio_pass = sprintf("%.3f",$sumAlt_pass / ($sumAlt_pass + $sumRef_pass));
	}

	my @output = ($sumRef,$sumAlt,$read_ratio,$nHomo,$nHeter,$nAlt,$cell_ratio,$Alt_str,$Ref_str,$sumRef_pass,$sumAlt_pass,$read_ratio_pass,$nPassHomo,$nPassHeter,$nPassAlt,$cell_ratio_pass,$Alt_depth_str,$Ref_depth_str);
	return(@output);
}


	


