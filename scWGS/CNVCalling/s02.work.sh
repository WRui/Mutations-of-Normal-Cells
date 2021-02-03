#!/bin/bash
#sample=SampleList.txt
#sample=SampleList_vivo.txt
sample=SampleList_Epcam.txt
cat $sample|while read sp 
do
	bash s02.splitBed.sh $sp
done
