#!/bin/bash
rootdir=/gpfs1/tangfuchou_pkuhpc/tangfuchou_test/wangrui/Project/Immune_Mutation/PublicCancerCell/03.SNP_Result
indir=$rootdir/SingleCell
outdir=$rootdir/MergeAddRGscBam

mkdir -p $outdir
for sp in CRC01 CRC02 CRC03 CRC04 CRC05 CRC06 CRC07 CRC08 CRC09 CRC11 CRC12 CRC13 CRC14 CRC15 CRC16 CRC17 CRC18 CRC19 CRC20 CRC21 CRC22 NOR01 NOR02 NOR03 NOR04 NOR05 NOR06
do
	mkdir -p $outdir/$sp
	echo "#!/bin/bash
/gpfs1/tangfuchou_pkuhpc/tangfuchou_test/wangrui/Software/IBM_Software/Software/samtools-1.2/samtools merge $outdir/$sp/$sp.bam $indir/$sp*/$sp*realn_Recal.bam " >WR_$sp.07.tmp.sh
sbatch -p cn-long -N 1 -A tangfuchou_g1 --qos=tangfuchoucnl --cpus-per-task=20 -o WR_$sp.07.tmp.sh.o%j -e WR_$sp.07.tmp.sh.e%j WR_$sp.07.tmp.sh
done
