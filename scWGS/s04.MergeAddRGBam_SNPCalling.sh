#!/bin/bash
dir=/gpfs1/tangfuchou_pkuhpc/tangfuchou_test/wangrui/Project/Immune_Mutation/PublicCancerCell/03.SNP_Result/MergeAddRGscBam
SAMTOOLS=/gpfs1/tangfuchou_pkuhpc/tangfuchou_test/wangrui/Software/IBM_Software/Software/samtools-1.2/samtools
Human_ref=/gpfs1/tangfuchou_pkuhpc/Pipeline/01.scmMALBAC_bsh/database/fasta/hg19.fa

GATK="java -jar /gpfs1/tangfuchou_pkuhpc/tangfuchou_test/wangrui/Software/IBM_Software/Software/GenomeAnalysisTK-3.8-0-ge9d806836/GenomeAnalysisTK.jar"

snpEff=/gpfs1/tangfuchou_pkuhpc/tangfuchou_test/wangrui/Software/IBM_Software/Software/snpEff_v4.3/snpEff/snpEff.jar
SnpSift=/gpfs1/tangfuchou_pkuhpc/tangfuchou_test/wangrui/Software/IBM_Software/Software/snpEff_v4.3/snpEff/SnpSift.jar
snpEff_config=/gpfs1/tangfuchou_pkuhpc/tangfuchou_test/wangrui/Software/IBM_Software/Software/snpEff_v4.3/snpEff/snpEff.config
Exon_target=/gpfs1/tangfuchou_pkuhpc/tangfuchou_test/wangrui/Database/IBM_Database/S07604514_Regions.bed
KnownSites_1=/gpfs1/tangfuchou_pkuhpc/tangfuchou_test/wangrui/Database/IBM_Database/dbSNP/dbsnp_135_sorted.hg19.vcf
ClinVar=/gpfs1/tangfuchou_pkuhpc/tangfuchou_test/wangrui/Database/ClinVar/clinvar_GRCh37.vcf
for sp in CRC16 CRC11 CRC12 CRC13 CRC02 CRC03 CRC04 CRC06 CRC07 CRC08 CRC09 CRC14 CRC15 CRC19 CRC21 CRC22 CRC01 CRC05 CRC20 NOR03 NOR04 NOR05 NOR06 CRC17 CRC18 NOR01 NOR02
do
	echo "#!/bin/bash

#$SAMTOOLS index $dir/$sp/$sp.bam


$GATK -T HaplotypeCaller -R $Human_ref -L $Exon_target -I $dir/$sp/$sp.bam -stand_call_conf 30.0 -o $dir/$sp/$sp.HaplotypeCaller.variants_result.Exon.vcf

java -Xmx4g -jar $snpEff -c $snpEff_config  hg19 $dir/$sp/$sp.HaplotypeCaller.variants_result.Exon.vcf >$dir/$sp/$sp.HaplotypeCaller.variants_result.Exon.ann.vcf

java -Xmx4g -jar $SnpSift annotate $KnownSites_1 $dir/$sp/$sp.HaplotypeCaller.variants_result.Exon.ann.vcf >$dir/$sp/$sp.HaplotypeCaller.variants_result.Exon.ann_dbSNP.vcf

java -Xmx4g -jar $SnpSift annotate $ClinVar $dir/$sp/$sp.HaplotypeCaller.variants_result.Exon.ann_dbSNP.vcf > $dir/$sp/$sp.HaplotypeCaller.variants_result.Exon.ann_dbSNP_ClinVar.vcf
" > WR_$sp.08.2.Exon.tmp.sh
sbatch -p cn-long -N 1 -A tangfuchou_g1 --qos=tangfuchoucnl --cpus-per-task=5 -o WR_$sp.08.2.Exon.tmp.sh.o%j -e WR_$sp.08.2.Exon.tmp.sh.e%j WR_$sp.08.2.Exon.tmp.sh
done
