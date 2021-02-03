#!/bin/bash
dir=$1
sample=$2
control=$3
cat $sample|while read sp 
do
echo "#!/bin/sh
source /gpfs1/tangfuchou_pkuhpc/tangfuchou_test/wangrui/Project/Immune_Mutation/Exon/WES_SNP_pipeline_cls.sh $dir $sp $control

do_QC
do_bwa_mapping
do_MarkDuplicates
do_RealignerTargetCreator
do_check_GATK RealignerTargetCreator
do_IndelRealigner
do_check_GATK IndelRealigner
do_BaseRecalibrator
do_check_GATK BaseRecalibrator
do_PrintReads
do_check_GATK PrintReads
do_HaplotypeCaller
do_HaplotypeCaller_chrM
do_check_GATK HaplotypeCaller
do_Haplo_VariantFilter
do_snpEff_Anno_Hap
do_SIFT_Polyphen_Anno_Hap
#do_ExtractVariant_Hap

## Somatic SNP Calling
#if [ \"$sp\" != \"$control\" ];
#then
	do_Mutect2
	do_Mutect2_chrM
	do_snpEff_Anno_Mutect
	do_SIFT_Polyphen_Anno_Mutect
#	do_ExtractVarint_Mutect
#elif
#	exit 0
#fi

" > WR_$sp.work.tmp.sh
cpu=20
partition=cn-long
qos=tangfuchoucnl
account=tangfuchou_g1
sbatch -p $partition -N 1 -A $account --qos=$qos --no-requeue --cpus-per-task=$cpu -o WR_$sp.work.tmp.sh.o%j -e WR_$sp.work.tmp.sh.e%j  WR_$sp.work.tmp.sh

done
