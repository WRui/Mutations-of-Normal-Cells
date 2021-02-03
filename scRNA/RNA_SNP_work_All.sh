#!/bin/bash
dir=$1
raw_data=$2
sample=$3

cat $sample|while read sp
do
echo "#!/bin/bash
source /gpfs1/tangfuchou_pkuhpc/tangfuchou_test/wangrui/Project/Immune_Mutation/scRNA_CRC/bin/RNA_SNP_pipeline_cls.sh $dir $raw_data $sp

do_QC
do_mapping
#do_ReorderSam #ERCC
#do_samTobam # ERCC
do_ReorderBam
do_RG_added_sorted
#do_RG_added_sorted_noRM # don't use
do_mark_dup
do_splitNTrim
do_RealignerTargetCreator
do_IndelRealigner
do_BaseRecalibrator
do_BaseRecalibrator_BQSR
do_PrintReads
do_HaplotypeCaller
#do_HaplotypeCaller_GVCF
#do_HaplotypeCaller_GVCF_V2
#do_HaplotypeCaller_GVCF_chrM
do_SnpEFF_annatation
do_HaplotypeCaller_GVCF_chrM_Right
#do_SnpEff_annotation_gVCF

" > WR_$sp.work.tmp.sh

cpu=10
partition=cn-long
qos=tangfuchoucnl
account=tangfuchou_g1
sbatch -p $partition -N 1 -A $account --qos=$qos --no-requeue --cpus-per-task=$cpu -o WR_$sp.work.tmp.sh.o%j -e WR_$sp.work.tmp.sh.e%j  WR_$sp.work.tmp.sh

done

