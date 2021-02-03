#!/bin/bash 
home=/gpft1/Software/ginkgo-master
dir=$1

source $dir/config
distMet=$distMeth
genome=${home}/genomes/${chosen_genome}
genome=${genome}/original

statFile=status.xml

echo "Launching process.R $genome $dir $statFile data $segMeth $binMeth $clustMeth $distMet $color ${ref}_mapped $f $facs $sex $rmbadbins"

paste $dir/C*_mapped > $dir/data
$home/scripts/process.R $genome $dir $statFile data $segMeth $binMeth $clustMeth $distMet $color ${ref}_mapped $f $facs $sex $rmbadbins
