bwa=/gpfs1/tangfuchou_pkuhpc/tangfuchou_test/wangrui/Software/IBM_Software/Software/bwa-0.7.5a/bwa
SAMTOOLS=/gpfs1/tangfuchou_pkuhpc/tangfuchou_test/wangrui/Software/IBM_Software/Software/samtools-1.2/samtools
PICARD="java -jar /gpfs1/tangfuchou_pkuhpc/tangfuchou_test/wangrui/Software/IBM_Software/Software/picard-tools-1.130/picard.jar"
GATK="java -jar /gpfs1/tangfuchou_pkuhpc/tangfuchou_test/wangrui/Software/IBM_Software/Software/GenomeAnalysisTK-3.8-0-ge9d806836/GenomeAnalysisTK.jar"

snpEff=/gpfs1/tangfuchou_pkuhpc/tangfuchou_test/wangrui/Software/IBM_Software/Software/snpEff_v4.3/snpEff/snpEff.jar
SnpSift=/gpfs1/tangfuchou_pkuhpc/tangfuchou_test/wangrui/Software/IBM_Software/Software/snpEff_v4.3/snpEff/SnpSift.jar
snpEff_config=/gpfs1/tangfuchou_pkuhpc/tangfuchou_test/wangrui/Software/IBM_Software/Software/snpEff_v4.3/snpEff/snpEff.config
SnpSift_db=/gpfs1/tangfuchou_pkuhpc/tangfuchou_test/wangrui/Database/IBM_Database/dbNSFP/hg19/dbNSFP.txt.gz

#Database

Human_ref=/gpfs1/tangfuchou_pkuhpc/Pipeline/01.scmMALBAC_bsh/database/fasta/hg19.fa
vcf=/gpfs1/tangfuchou_pkuhpc/tangfuchou_test/wangrui/Database/IBM_Database/indel_annotation/Mills_and_1000G_gold_standard.indels.hg19.vcf


knownSites_1=/gpfs1/tangfuchou_pkuhpc/tangfuchou_test/wangrui/Database/IBM_Database/dbSNP/dbsnp_135_sorted.hg19.vcf
knownSites_2=/gpfs1/tangfuchou_pkuhpc/tangfuchou_test/wangrui/Database/IBM_Database/indel_annotation/Mills_and_1000G_gold_standard.indels.hg19.vcf
knownSites_3=/gpfs1/tangfuchou_pkuhpc/tangfuchou_test/wangrui/Database/IBM_Database/dbSNP/1000G_phase1.indels.hg19.vcf


indir=$1
outdir=$2
sp=$3

function do_MarkDuplicates_sc {

mkdir -p $outdir/$sp
$PICARD MarkDuplicates I=$indir/$sp.bam O=$outdir/$sp/$sp.Mdu.sort.bam M=$outdir/$sp/marked_dup_metrics.txt CREATE_INDEX=TRUE
}


function do_RG_add_sc {

$PICARD AddOrReplaceReadGroups I=$outdir/$sp/$sp.Mdu.sort.bam O=$outdir/$sp/$sp.Mdu.sort.addRG.bam SO=coordinate RGID=$sp RGLB=$sp RGPL=illumina RGPU=$sp RGSM=$sp

$SAMTOOLS index $outdir/$sp/$sp.Mdu.sort.addRG.bam
}


function do_BaseRecalibrator_sc {

$GATK -T BaseRecalibrator -R $Human_ref  -I $outdir/$sp/$sp.Mdu.sort.addRG.bam -knownSites $knownSites_1 -o $outdir/$sp/$sp.recal.grp

}

function do_PrintReads_sc {

$GATK -T PrintReads -R $Human_ref -I $outdir/$sp/$sp.Mdu.sort.addRG.bam -BQSR $outdir/$sp/$sp.recal.grp -o $outdir/$sp/$sp.realn_Recal.bam

}


function do_HaplotypeCaller_sc {

$GATK -T HaplotypeCaller -R $Human_ref -I $outdir/$sp/$sp.realn_Recal.bam -stand_call_conf 30.0 -o $outdir/$sp/$sp.HaplotypeCaller.variants_result.vcf

}

function do_HaplotypeCaller_gvcf_sc {

bed_file=/gpfs1/tangfuchou_pkuhpc/tangfuchou_test/wangrui/Project/Immune_Mutation/PublicCancerCell/bin/All_Mutant_Pos.bed

$GATK -T HaplotypeCaller -R $Human_ref -I $outdir/$sp/$sp.realn_Recal.bam -L $bed_file -stand_call_conf 30.0 -ERC BP_RESOLUTION -o $outdir/$sp/$sp.HaplotypeCaller.variants_result.gvcf

}



###############################

function do_MarkDuplicates {

$PICARD MarkDuplicates I=$indir/$sp/$sp.bam O=$indir/$sp/$sp.Mdu.sort.bam M=$indir/$sp/marked_dup_metrics.txt CREATE_INDEX=TRUE

}

function do_RG_add {

$PICARD AddOrReplaceReadGroups I=$indir/$sp/$sp.Mdu.sort.bam O=$indir/$sp/$sp.Mdu.sort.addRG.bam SO=coordinate RGID=$sp RGLB=$sp RGPL=illumina RGPU=$sp RGSM=$sp

$SAMTOOLS index $indir/$sp/$sp.Mdu.sort.addRG.bam

}



function do_BaseRecalibrator {

$GATK -T BaseRecalibrator -R $Human_ref  -I $indir/$sp/$sp.Mdu.sort.addRG.bam -knownSites $knownSites_1  -o $indir/$sp/$sp.recal.grp

}


function do_PrintReads {

$GATK -T PrintReads -R $Human_ref -I $indir/$sp/$sp.Mdu.sort.addRG.bam -BQSR $indir/$sp/$sp.recal.grp -o $indir/$sp/$sp.realn_Recal.bam

}

function do_HaplotypeCaller {
mkdir -p $outdir
mkdir -p $outdir/$sp
$GATK -T HaplotypeCaller -R $Human_ref -I $indir/$sp/$sp.realn_Recal.bam -stand_call_conf 30.0 -o $outdir/$sp/$sp.HaplotypeCaller.variants_result.vcf

}

function do_HaplotypeCaller_gvcf {
mkdir -p $outdir
mkdir -p $outdir/$sp
$GATK -T HaplotypeCaller -R $Human_ref -I $indir/$sp/$sp.realn_Recal.bam -stand_call_conf 30.0 -ERC BP_RESOLUTION  -o $outdir/$sp/$sp.HaplotypeCaller.variants_result.gvcf
}

#################### Annotation
function do_snpEff_Anno_Hap {
java -Xmx4g -jar $snpEff -c $snpEff_config  hg19 $outdir/$sp/$sp.HaplotypeCaller.variants_result.vcf >$outdir/$sp/$sp.HaplotypeCaller.ann.vcf
}

function do_snpSift_dbSNP_Hap {
java -Xmx4g -jar  $SnpSift annotate $knownSites_1 $outdir/$sp/$sp.HaplotypeCaller.ann.vcf > $outdir/$sp/$sp.HaplotypeCaller.ann_dbsnp.vcf
}
