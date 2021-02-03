#!/bin/bash


# setting
dir=$1
raw_data=$2
indir=$dir/$raw_data
outpath=$dir/00.clean_data
outdir=$dir/01.Tophat
mkdir -p $indor
mkdir -p $outdir
mkdir -p $outpath
sp=$3

#scripts
QC_script=/gpfs1/tangfuchou_pkuhpc/tangfuchou_test/wangrui/Software/bin/QC_plus_rm_primer_polyA_T.pl
tophat=/apps/bioinfo/tophat-2.0.12.Linux_x86_64/tophat

gtf=/gpfs1/tangfuchou_pkuhpc/tangfuchou_test/wangrui/Database/IBM_Database/RNA_Database/hg19/refGene_chrM.gtf
genome=/gpfs1/tangfuchou_pkuhpc/tangfuchou_test/wangrui/Database/IBM_Database/bowtie2_index/hg19/Bowtie2Index/genome

SAMTOOLS=/gpfs1/tangfuchou_pkuhpc/tangfuchou_test/wangrui/Software/IBM_Software/Software/samtools-1.2/samtools
PICARD="java -jar /gpfs1/tangfuchou_pkuhpc/tangfuchou_test/wangrui/Software/IBM_Software/Software/picard-tools-1.130/picard.jar"
GATK="java -jar /gpfs1/tangfuchou_pkuhpc/tangfuchou_test/wangrui/Software/IBM_Software/Software/GenomeAnalysisTK-3.8-0-ge9d806836/GenomeAnalysisTK.jar"

snpEff=/gpfs1/tangfuchou_pkuhpc/tangfuchou_test/wangrui/Software/IBM_Software/Software/snpEff_v4.3/snpEff/snpEff.jar
SnpSift=/gpfs1/tangfuchou_pkuhpc/tangfuchou_test/wangrui/Software/IBM_Software/Software/snpEff_v4.3/snpEff/SnpSift.jar
snpEff_config=/gpfs1/tangfuchou_pkuhpc/tangfuchou_test/wangrui/Software/IBM_Software/Software/snpEff_v4.3/snpEff/snpEff.config
H_fai=/gpfs1/tangfuchou_pkuhpc/tangfuchou_test/wangrui/Database/IBM_Database/GATK/genome.fa.fai
Human_ref=/gpfs1/tangfuchou_pkuhpc/tangfuchou_test/wangrui/Database/IBM_Database/GATK/genome.fa

vcf=/gpfs1/tangfuchou_pkuhpc/tangfuchou_test/wangrui/Database/IBM_Database/indel_annotation/Mills_and_1000G_gold_standard.indels.hg19.vcf
knownSites_1=/gpfs1/tangfuchou_pkuhpc/tangfuchou_test/wangrui/Database/IBM_Database/dbSNP/dbsnp_135.hg19.vcf
knownSites_2=/gpfs1/tangfuchou_pkuhpc/tangfuchou_test/wangrui/Database/IBM_Database/indel_annotation/Mills_and_1000G_gold_standard.indels.hg19.vcf
knownSites_3=/gpfs1/tangfuchou_pkuhpc/tangfuchou_test/wangrui/Database/IBM_Database/dbSNP/1000G_phase1.indels.hg19.vcf
spike_in=/gpfs1/tangfuchou_pkuhpc/tangfuchou_test/wangrui/Database/IBM_Database/Share_Database/Database/GATK/ERCC_RGC.list

##set enviroment 
export PATH=/gpfs1/tangfuchou_pkuhpc/tangfuchou_test/wangrui/Software/NewInstall_Software/ActivePerl-5.28.1/WR_Install/bin:$PATH
export PERL5LIB=/gpfs1/tangfuchou_pkuhpc/tangfuchou_test/wangrui/Software/NewInstall_Software/ActivePerl-5.28.1/WR_Install/lib:$PERL5LIB
export PERL5LIB=/gpfs1/tangfuchou_pkuhpc/tangfuchou_test/wangrui/Software/NewInstall_Software/ActivePerl-5.28.1/WR_Install/lib/lib/perl5/:$PERL5LIB
export MANPATH=/gpfs1/tangfuchou_pkuhpc/tangfuchou_test/wangrui/Software/NewInstall_Software/ActivePerl-5.28.1/WR_Install/man:$MANPATH
PERL_MB_OPT="--install_base \"/gpfs1/tangfuchou_pkuhpc/tangfuchou_test/wangrui/Software/NewInstall_Software/ActivePerl-5.28.1/WR_Install/lib\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=/gpfs1/tangfuchou_pkuhpc/tangfuchou_test/wangrui/Software/NewInstall_Software/ActivePerl-5.28.1/WR_Install/lib"; export PERL_MM_OPT;
export PERL_LOCAL_LIB_ROOT=/gpfs1/tangfuchou_pkuhpc/tangfuchou_test/wangrui/Software/NewInstall_Software/ActivePerl-5.28.1/WR_Install/lib:$PERL_LOCAL_LIB_ROOT
export PATH=/gpfs1/tangfuchou_pkuhpc/tangfuchou_test/wangrui/Software/IBM_Software/Software/java/jdk1.8.0_151/bin:$PATH



function do_QC {
mkdir -p $outpath/$sp
perl $QC_script -indir $indir -outdir $outpath -sample $sp -end 2 -scRNA 1
}

function do_mapping {
export PATH=/gpfs1/tangfuchou_pkuhpc/tangfuchou_test/wangrui/Software/NewInstall_Software/anaconda/bin:$PATH
export PYTHONPATH=/gpfs1/tangfuchou_pkuhpc/tangfuchou_test/wangrui/Software/NewInstall_Software/anaconda/lib/python2.7/site-packages/:$PYTHONPATH
export PATH=/gpfs1/tangfuchou_pkuhpc/tangfuchou_test/wangrui/Software/IBM_Software/Software/samtools-0.1.18:$PATH
mkdir -p $outpath/$sp
$tophat -p 3 -G $gtf -o $outdir/$sp --library-type fr-unstranded $genome $outpath/$sp/$sp.R1.clean.fq.gz  $outpath/$sp/$sp.R2.clean.fq.gz
}

function do_Remove_ERCC {

cat $spike_in| grep -f - -v <($SAMTOOLS view -h $outdir/$sp/accepted_hits.bam) > $outdir/$sp/$sp.NSI.sam

}


function do_ReorderSam {

$PICARD ReorderSam I=$outdir/$sp/$sp.NSI.sam O=$outdir/$sp/$sp.reorder.sam REFERENCE=$Human_ref

}

function do_samTobam {

$SAMTOOLS view -bS $outdir/$sp/$sp.reorder.sam -o $outdir/$sp/$sp.reorder.bam

}

function do_ReorderBam {

$PICARD ReorderSam I=$outdir/$sp/accepted_hits.bam O=$outdir/$sp/$sp.reorder.bam REFERENCE=$Human_ref
}

function do_RG_added_sorted {

$PICARD AddOrReplaceReadGroups I=$outdir/$sp/$sp.reorder.bam O=$outdir/$sp/$sp.rg_added_sorted.bam SO=coordinate RGID=$sp RGLB=$sp RGPL=illumina RGPU=$sp RGSM=$sp

}

#function do_RG_added_sorted_noRM {

#$PICARD AddOrReplaceReadGroups I=$outdir/$sp/accepted_hits.bam O=$outdir/$sp/$sp.rg_added_sorted.bam SO=coordinate RGID=$sp RGLB=$sp RGPL=illumina RGPU=$sp RGSM=$sp

#}


function do_mark_dup {

$PICARD MarkDuplicates I=$outdir/$sp/$sp.rg_added_sorted.bam O=$outdir/$sp/$sp.dedupped.bam  CREATE_INDEX=true VALIDATION_STRINGENCY=SILENT M=$outdir/$sp/$sp.metrics

}


function do_splitNTrim {

$SAMTOOLS index $outdir/$sp/$sp.dedupped.bam
$GATK -T SplitNCigarReads -R $Human_ref -I $outdir/$sp/$sp.dedupped.bam -o $outdir/$sp/$sp.split.bam -rf ReassignOneMappingQuality -RMQF 255 -RMQT 60 -U ALLOW_N_CIGAR_READS

}


function do_RealignerTargetCreator {

$GATK -T RealignerTargetCreator -R $Human_ref -I $outdir/$sp/$sp.split.bam -o $outdir/$sp/$sp.forIndelRealigner.intervals -known $vcf
}

function do_IndelRealigner {

$GATK -T IndelRealigner -R $Human_ref -I $outdir/$sp/$sp.split.bam -targetIntervals $outdir/$sp/$sp.forIndelRealigner.intervals -o $outdir/$sp/$sp.realignedBam.bam -known $vcf

}


function do_BaseRecalibrator {

$GATK -T BaseRecalibrator -R $Human_ref -I $outdir/$sp/$sp.realignedBam.bam -knownSites $knownSites_1 -knownSites $knownSites_2 -knownSites $knownSites_3 -o $outdir/$sp/$sp.recal.grp

}


function do_BaseRecalibrator_BQSR {

$GATK -T BaseRecalibrator -R $Human_ref -I $outdir/$sp/$sp.realignedBam.bam -knownSites $knownSites_1 -knownSites $knownSites_2 -knownSites $knownSites_3 -BQSR $outdir/$sp/$sp.recal.grp -o $outdir/$sp/$sp.pos_recal.grp

}



function do_PrintReads {

$GATK -T PrintReads -R $Human_ref -I $outdir/$sp/$sp.realignedBam.bam  -BQSR $outdir/$sp/$sp.recal.grp -o $outdir/$sp/$sp.realn_Recal.bam

}


function do_HaplotypeCaller {

$GATK -T HaplotypeCaller -R $Human_ref -I $outdir/$sp/$sp.realn_Recal.bam -dontUseSoftClippedBases -stand_call_conf 20.0 -o  $outdir/$sp/$sp.variants_result.vcf #-stand_emit_conf 20.0

}


function do_HaplotypeCaller_GVCF {

$GATK -T HaplotypeCaller -R $Human_ref -I $outdir/$sp/$sp.realn_Recal.bam -G StandardAnnotation --emitRefConfidence GVCF -dontUseSoftClippedBases -stand_call_conf 20.0  -variant_index_type LINEAR -variant_index_parameter 128000 -o $outdir/$sp/$sp.variants_result.AS.g.vcf #-stand_emit_conf 20.0

}

function do_HaplotypeCaller_GVCF_chrM_Right {

$GATK -T HaplotypeCaller -R $Human_ref -I $outdir/$sp/$sp.realn_Recal.bam -L chrM -G StandardAnnotation --emitRefConfidence BP_RESOLUTION -dontUseSoftClippedBases -variant_index_type LINEAR -variant_index_parameter 128000 -o $outdir/$sp/$sp.variants_result.chrM.AS.g.vcf

}


function do_HaplotypeCaller_GVCF_V2 {

$GATK -T HaplotypeCaller -R $Human_ref -I $outdir/$sp/$sp.realn_Recal.bam -G StandardAnnotation --emitRefConfidence GVCF -o $outdir/$sp/$sp.variants_result.g.vcf -stand_call_conf 20 --output_mode EMIT_ALL_SITES #-stand_emit_conf 20.0
}


function do_HaplotypeCaller_GVCF_chrM {

$GATK -T HaplotypeCaller -R $Human_ref -I $outdir/$sp/$sp.realn_Recal.bam -G StandardAnnotation --emitRefConfidence GVCF -o $outdir/$sp/$sp.variants_result.chrM.g.vcf -stand_call_conf 20 --output_mode EMIT_ALL_SITES -L chrM #-stand_emit_conf 20.0

}



function do_SnpEFF_annatation {

java -Xmx10g -jar $snpEff -c $snpEff_config hg19 $outdir/$sp/$sp.variants_result.vcf >$outdir/$sp/$sp.ann.vcf

}


function do_SnpEff_annotation_gVCF {

java -Xmx10g -jar $snpEff -c $snpEff_config hg19  $outdir/$sp/$sp.variants_result.AS.g.vcf > $outdir/$sp/$sp.ann.g.vcf

}
