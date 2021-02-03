#!/bin/bash
indir=$1
outdir=$2
sample=$3

cat $sample|while read sp
do
echo "#!/bin/bash
source /gpfs1/tangfuchou_pkuhpc/tangfuchou_test/wangrui/Project/Immune_Mutation/PublicCancerCell/bin/WGS_SNP_Calling_PipeLine.sh $indir $outdir $sp

#do_MarkDuplicates_sc
#do_RG_add_sc
#do_BaseRecalibrator_sc
#do_PrintReads_sc
#do_HaplotypeCaller_sc
#do_snpEff_Anno_Hap
do_snpSift_dbSNP_Hap
" > WR_$sp.sc.work.tmp.sh

#cpu=10
cpu=1
partition=cn-long
qos=tangfuchoucnl
account=tangfuchou_g1
sbatch -p $partition -N 1 -A $account --qos=$qos --no-requeue --cpus-per-task=$cpu -o WR_$sp.sc.work.tmp.sh.o%j -e WR_$sp.sc.work.tmp.sh.e%j WR_$sp.sc.work.tmp.sh

done
