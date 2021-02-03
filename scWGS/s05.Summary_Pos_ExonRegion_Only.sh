#!/bin/bash
indir=/gpfs1/tangfuchou_pkuhpc/tangfuchou_test/wangrui/Project/Immune_Mutation/PublicCancerCell/03.SNP_Result/MergeAddRGscBam
outdir=/gpfs1/tangfuchou_pkuhpc/tangfuchou_test/wangrui/Project/Immune_Mutation/PublicCancerCell/07.Pos_Summary
script=/gpfs1/tangfuchou_pkuhpc/tangfuchou_test/wangrui/Project/Immune_Mutation/PublicCancerCell/bin/PosMutType_Cal_scDNA_addClinVar.pl
script2=/gpfs1/tangfuchou_pkuhpc/tangfuchou_test/wangrui/Project/Immune_Mutation/PublicCancerCell/bin/PosMutType_Cal_scDNA_addClinVar_invitro.pl
script3=/gpfs1/tangfuchou_pkuhpc/tangfuchou_test/wangrui/Project/Immune_Mutation/PublicCancerCell/bin/PosMutType_Cal_scDNA_addClinVar_invivo.pl
depth=2
#sampleList=$1
mkdir -p $outdir
#cat $sampleList|while read sp 
for sp in CRC16 #CRC12 CRC13  #CRC01 CRC02 CRC03 CRC04 CRC05 CRC06 CRC07 CRC08 CRC09 CRC14 CRC15 CRC17 CRC18 CRC19 CRC20 CRC21 CRC22 NOR01 NOR02 NOR03 NOR04 NOR05 NOR06 
do
	mkdir -p $outdir/$sp
	echo "#!/bin/bash
perl $script --indir $indir --outdir $outdir --sample $sp --depth $depth" > WR_09.Exon.$sp.tmp.sh
sbatch -p cn-long -N 1 -A tangfuchou_g1 --qos=tangfuchoucnl --cpus-per-task=5 -o WR_09.Exon.$sp.tmp.sh.o%j -e WR_09.Exon.$sp.tmp.sh.e%j WR_09.Exon.$sp.tmp.sh
done



for sp in CRC16
do
	echo "#!/bin/bash
perl $script2 --indir $indir --outdir $outdir --sample $sp --depth $depth" > WR_09.Exon.$sp.vitro.tmp.sh

echo "#!/bin/bash
perl $script3 --indir $indir --outdir $outdir --sample $sp --depth $depth" > WR_09.Exon.$sp.vivo.tmp.sh
done

