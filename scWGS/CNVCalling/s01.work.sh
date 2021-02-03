#!/bin/bash
#sample=SampleList.txt
#sample=SampleList_vivo.txt
sample=SampleList_Epcam.txt
cat $sample|while read sp 
do
	bash s01.Bam2Bed.sh $sp
done
