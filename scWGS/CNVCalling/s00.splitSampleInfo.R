data <- read.table("Sample_Info_vivoPT.Epcam.txt",header=F,sep="\t")

DNA_lib <- unique(data$V2)
for(i in DNA_lib){
	tmp_data <- data[data$V2==i,]
	writeDf <- data.frame(Sample=tmp_data[,1],bar1=rep(0,nrow(tmp_data)),bar2=tmp_data[,3])
	write.table(file=paste(i,".Info",sep=""),writeDf,quote=F,sep="\t",row.names=F,col.names=F)
}
