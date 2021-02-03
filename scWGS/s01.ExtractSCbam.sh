#!/bin/bash
SampleList=$1
bamDir=/gpfs1/tangfuchou_pkuhpc/tangfuchou_test/wangrui/Project/Immune_Mutation/PublicCancerCell/00.OriginalBam
SampleDir=/gpfs1/tangfuchou_pkuhpc/tangfuchou_test/wangrui/Project/Immune_Mutation/PublicCancerCell/bin/SampleList
outdir=/gpfs1/tangfuchou_pkuhpc/tangfuchou_test/wangrui/Project/Immune_Mutation/PublicCancerCell/01.SplitBam

cat $SampleList|while read sp 
do
	echo "#!/bin/bash
python Extract_reads.py -b $bamDir/${sp}_mapQ30_sort_rmdup.bam -n $SampleDir/${sp}.txt -o $outdir" > WR_$sp.Extract.tmp.sh
sbatch -p cn-long -N 1 -A tangfuchou_g1 --qos=tangfuchoucnl --cpus-per-task=4 -o WR_$sp.Extract.tmp.sh.o%j -e WR_$sp.Extract.tmp.sh.e%j WR_$sp.Extract.tmp.sh
done
