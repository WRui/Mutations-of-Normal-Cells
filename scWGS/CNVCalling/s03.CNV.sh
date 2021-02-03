#!/bin/bash 
dir=/gpfs1/tangfuchou_pkuhpc/tangfuchou_test/wangrui/Project/Immune_Mutation/PublicCancerCell/11.Bam2Bed
mkdir -p $dir/01.CNV
outdir=$dir/01.CNV
#BatchList=$1
#BatchList=SampleList.txt
#BatchList=SampleList_vivo.txt
BatchList=SampleList_Epcam.txt
cat $BatchList|while read batch
do
	mkdir -p $outdir/$batch
	ln -s $dir/00.bed/$batch/*bed.gz $outdir/$batch
	cp $dir/bin/script/config $outdir/$batch
	ln -s $dir/bin/script/normal.bed.gz_mapped $outdir/$batch
	cp $dir/bin/script/analyze_simple_*.sh $outdir/$batch	
	bash $dir/bin/script/work01.sh $dir/01.CNV/$batch $dir/bin/$batch
	sbatch -p cn-long -N 1 -A tangfuchou_g1 --qos=tangfuchoucnl --cpus-per-task=10 -o $dir/01.CNV/$batch/WR_run01.tmp.sh.o%j -e $dir/01.CNV/$batch/WR_run01.tmp.sh.e%j $dir/01.CNV/$batch/WR_run01.tmp.sh
done

