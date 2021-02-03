#!/bin/bash
#indir=/gpfs1/tangfuchou_pkuhpc/tangfuchou_test/wangrui/Project/Immune_Mutation/PublicCancerCell/03.SNP_Result/PatientRegionCellType
indir=/gpfs1/tangfuchou_pkuhpc/tangfuchou_test/wangrui/Project/Immune_Mutation/PublicCancerCell/03.SNP_Result/CultureFibro
#SampleList=/gpfs1/tangfuchou_pkuhpc/tangfuchou_test/wangrui/Project/Immune_Mutation/PublicCancerCell/03.SNP_Result/PatientRegionCellType.txt
SampleList=/gpfs1/tangfuchou_pkuhpc/tangfuchou_test/wangrui/Project/Immune_Mutation/PublicCancerCell/03.SNP_Result/CultureFibro.txt
#script=$2
script=/gpfs1/tangfuchou_pkuhpc/tangfuchou_test/wangrui/Project/Immune_Mutation/PublicCancerCell/bin/Cal_ATCG_MutantRatio.pl
outdir=/gpfs1/tangfuchou_pkuhpc/tangfuchou_test/wangrui/Project/Immune_Mutation/PublicCancerCell/09.ATCG_MutantRatio
mkdir -p $outdir
cat $SampleList|while read sp 
do
	echo "#!/bin/bash
perl $script --indir $indir --outdir $outdir --sample $sp" > WR_s12.$sp.tmp.sh
sbatch -p cn-long -N 1 -A tangfuchou_g1 --qos=tangfuchoucnl --cpus-per-task=5 -o WR_s12.$sp.tmp.sh.o%j -e WR_s12.$sp.tmp.sh.e%j WR_s12.$sp.tmp.sh
done
