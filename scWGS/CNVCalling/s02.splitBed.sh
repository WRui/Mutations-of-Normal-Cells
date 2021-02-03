bwa_dir=/gpfs1/tangfuchou_pkuhpc/tangfuchou_test/wangrui/Project/Immune_Mutation/PublicCancerCell/00.OriginalBam
cnv_dir=/gpfs1/tangfuchou_pkuhpc/tangfuchou_test/wangrui/Project/Immune_Mutation/PublicCancerCell/11.Bam2Bed/00.bed
bin_dir=/gpfs1/tangfuchou_pkuhpc/tangfuchou_test/wangrui/Project/Immune_Mutation/PublicCancerCell/11.Bam2Bed/bin
mkdir -p $cnv_dir
sample=$1
mkdir -p $cnv_dir/$sample

echo "#!/bin/bash" > WR_$sample.grep_work.sh
echo "#!/bin/bash

cat $cnv_dir/${sample}/merge_sampleInfo|while read line; do seq=\`echo \$line | awk '{print \$2}'\` && sam=\`echo \$line | awk '{print \$3}'\` && echo \"zcat $cnv_dir/${sample}_mapQ30_sort_rmdup.bed| grep \$seq | gzip > $cnv_dir/$sample/\$sam.bed.gz\" ;done >> WR_$sample.grep_work.sh

" > $sample.02.tmp.sh
bash $sample.02.tmp.sh
sbatch -p cn-long -N 1 -A tangfuchou_g1 --qos=tangfuchoucnl --cpus-per-task=5 -o WR_$sample.grep_work.sh.o%j -e WR_$sample.grep_work.sh.e%j WR_$sample.grep_work.sh
