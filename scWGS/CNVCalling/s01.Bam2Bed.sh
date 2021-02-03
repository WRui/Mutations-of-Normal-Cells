#!/bin/bash
bwa_dir=/gpfs1/tangfuchou_pkuhpc/tangfuchou_test/wangrui/Project/Immune_Mutation/PublicCancerCell/00.OriginalBam
cnv_dir=/gpfs1/tangfuchou_pkuhpc/tangfuchou_test/wangrui/Project/Immune_Mutation/PublicCancerCell/11.Bam2Bed/00.bed
bin_dir=/gpfs1/tangfuchou_pkuhpc/tangfuchou_test/wangrui/Project/Immune_Mutation/PublicCancerCell/11.Bam2Bed/bin
mkdir -p $cnv_dir
sample=$1
mkdir -p $cnv_dir/$sample
echo "#!/bin/bash
/lustre1/tangfuchou_pkuhpc/Software/bedtools2/bin/bamToBed -i $bwa_dir/${sample}_mapQ30_sort_rmdup.bam |gzip >$cnv_dir/${sample}_mapQ30_sort_rmdup.bed.gz

export PATH=/gpfs1/tangfuchou_pkuhpc/tangfuchou_test/wangrui/Software/IBM_Software/Software/R-3.6.1/install_WR/bin:\$PATH
export R_LIBS=/gpfs1/tangfuchou_pkuhpc/tangfuchou_test/wangrui/Software/IBM_Software/Software/R-3.6.1/library:\$R_LIBS


Rscript $bin_dir/split_barcode_bed_CLS.R $cnv_dir/$sample $bin_dir $cnv_dir/$sample

" > WR_$sample.00.tmp.sh

sbatch -p cn-long -N 1 -A tangfuchou_g1 --qos=tangfuchoucnl --cpus-per-task=8 -o WR_$sample.00.tmp.sh.o%j -e WR_$sample.00.tmp.sh.e%j WR_$sample.00.tmp.sh
