#!/bin/bash
# ==============================================================================
# == Launch analysis
# ==============================================================================

# ------------------------------------------------------------------------------
# -- Variables
# ------------------------------------------------------------------------------
home=/gpfs1/Software/ginkgo-master
dir=$1
sample=$2
source ${dir}/config
distMet=$distMeth

inFile=list
statFile=status.xml
genome=${home}/genomes/${chosen_genome}
genome=${genome}/original

${home}/scripts/binUnsorted ${genome}/${binMeth} `wc -l < ${genome}/${binMeth}` <(zcat -cd ${dir}/${sample}.bed.gz) $sample ${dir}/${sample}_mapped


