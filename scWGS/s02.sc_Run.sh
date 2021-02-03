#!/bin/bash
rootdir=/gpfs1/tangfuchou_pkuhpc/tangfuchou_test/wangrui/Project/Immune_Mutation/PublicCancerCell
mkdir -p $rootdir/03.SNP_Result/SingleCell
PatientList=/gpfs1/tangfuchou_pkuhpc/tangfuchou_test/wangrui/Project/Immune_Mutation/PublicCancerCell/bin/PatientList
sp=$1
bash s02.WGS_sc_work.sh $rootdir/01.SplitBam $rootdir/03.SNP_Result/SingleCell $PatientList/$sp.txt
