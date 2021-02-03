#!/bin/bash
script=/gpfs1/tangfuchou_pkuhpc/tangfuchou_test/wangrui/Project/Immune_Mutation/PublicCancerCell/11.Bam2Bed/bin/script/analyze_simple_01.sh
dir=$1
sampleList=$2
rm -f $dir/WR_run01.tmp.sh
rm -f $dir/list
echo "#!/bin/bash" >$dir/WR_run01.tmp.sh
cut -f 1 ${sampleList}.Info|while read sp 
do
	echo "$script $dir $sp" >> $dir/WR_run01.tmp.sh
	
	echo "$sp.bed.gz" >>$dir/list
done
