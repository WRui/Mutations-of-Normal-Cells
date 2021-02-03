#setwd("D:/project/00.bin/190401_multiplexed_MALBAC")
#batch <- c("CRC_11_DA1")
#bin_dir <- ("D:/project/00.bin/190401_multiplexed_MALBAC")

argv <- commandArgs(TRUE)
batch <- argv[1]
bin_dir <- argv[2]
outdir <- argv[3]

bc <- read.table( paste( bin_dir,"/ZY_barcode_withGAT_whitelist", sep = ""), header = F, col.names = c("bc_seq","bc_id"))
saminfo <- read.table(paste(bin_dir,"/",gsub(".*/","",batch),".Info",sep=""), header = F, col.names = c("Sample","R_bc","D_bc"))
saminfo$R_bc <- NULL
saminfo$D_bc <- paste("sc", saminfo$D_bc, sep = "")

library(reshape2)
df.merge <- merge(bc, saminfo, by.x = "bc_id", by.y = "D_bc")
#df.merge
paste(batch,"/","merge_sampleInfo",sep="")
write.table(df.merge, paste(batch,"/","merge_sampleInfo",sep=""), append = F, sep = "\t", quote = F, col.names = F, row.names = F)


#library(data.table)
#bedfile=paste(batch, "_mapQ30_sort_rmdup.bed.gz", sep = "")
#bedfile
#bed <- fread(bedfile )
#
#
#############################
## Method 1:
#############################
#bc <- sapply( strsplit(as.character(bed$V4), "_"), "[[", 2)

#for (bc_i in unique(df.merge$bc_seq) ){
#  index_r <- which(bc == bc_i)
#  df.out  <- bed[index_r,]
#  sam_i <- as.vector( df.merge[ which( df.merge$bc_seq == bc_i),"Sample"] )
#  write.table(df.out, paste(outdir,"/",sam_i,".bed", sep = ""), append = F, sep = "\t", quote = F, col.names = F, row.names = F)
#}



#############################
## Method 2:
#############################
#i=1
#line = bed[i,4]
#bc_i <-  sapply( strsplit(as.character(line), "_"), "[[", 2)
#sam_i <- as.vector( df.merge[ which( df.merge$bc_seq == bc_i),"Sample"] )
#write.table(bed[i,], paste(outdir,"/",sam_i,".bed", sep = ""), append = T, sep = "\t", quote = F, col.names = F, row.names = F)







