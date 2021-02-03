#!/bin/bash
dir=/gpfs1/tangfuchou_pkuhpc/tangfuchou_test/wangrui/Project/Immune_Mutation/PublicCancerCell/11.Bam2Bed
outdir=$dir/01.CNV
#BatchList=SampleList.txt
#BatchList=SampleList_vivo.txt
BatchList=SampleList_Epcam.txt
cat $BatchList|while read batch
do
	echo "#!/bin/bash
bash $dir/bin/script/analyze_simple_02.sh $dir/01.CNV/$batch 
" > $dir/01.CNV/$batch/WR_run02.tmp.sh
 sbatch -p cn-long -N 1 -A tangfuchou_g1 --qos=tangfuchoucnl --cpus-per-task=10 -o $dir/01.CNV/$batch/WR_run02.tmp.sh.o%j -e $dir/01.CNV/$batch/WR_run02.tmp.sh.e%j $dir/01.CNV/$batch/WR_run02.tmp.sh
done
