#! /usr/bin/env python

'''
https://timoast.github.io/blog/2015-10-12-extractreads/

https://bioinformatics.stackexchange.com/questions/3380/how-to-subset-a-bam-by-a-list-of-qnames

https://github.com/pysam-developers/pysam/issues/509

https://dryad.figshare.com/articles/Extract_reads_from_bam_file_based_on_presence_of_specific_allele/6057542/1
'''
import pysam

def get_names(names):
	with open(names,'r') as infile:
		Bar_Sam = {}
		for line in infile:
			barcode,sample = line.strip().split(',')
			Bar_Sam[barcode] = sample
	return Bar_Sam

## outfhs dict of outbam file 
#outfh={}

#bamfile = pysam.AlignmentFile(options.bam, 'rb')
#bamfile.close()
#for sample in Bar_Sam.values():
#	outfh[sample] = pysam.AlignmentFile("%s/%s.bam" % (options.out,sample),"wb",template=bamfile)

#bamfile.close()

def extract_reads(options,Bar_Sam):
#	Bar_Sam = get_names(options.names)
	bamfile = pysam.AlignmentFile(options.bam, 'rb')
	for r in bamfile:
		barcode_seq = r.query_name.split('_')[1][0:8]
		if barcode_seq in Bar_Sam.keys():
			sample = Bar_Sam[barcode_seq]
			outfh[sample].write(r)
			#with pysam.AlignmentFile("%s.bam" % sample,"wb",template=bamfile) as outf:
				#outf.write(r)
			#outbamName=sample+'.bam'
			#pysam.AlignmentFile(outbamName,mode='wb',template=bamfile).write(r)



#infile=pysam.AlignmentFile('in.bam')
#outfile=pysam.AlignmentFile('out.bam',mode='wb')


#for aln_read in infile:
#	qname = aln_read.query_name
#	for barcode in 
#	if aln_read.query_name in fq:
#		outfile.write(aln)


if __name__ == "__main__":
	from argparse import ArgumentParser
	
	parser = ArgumentParser(description='Split reads by read name from bam file')
	parser.add_argument('-b','--bam',help='bam file', required = True)
	parser.add_argument('-n','--names',help='list of barcode sequence and sample names',required= True)
	parser.add_argument('-o','--out',help='file path for output bam files',required= True)
	options = parser.parse_args()
	
	outfh={}
	bamfile = pysam.AlignmentFile(options.bam, 'rb')
	Bar_Sam = get_names(options.names)

	bamfile = pysam.AlignmentFile(options.bam, 'rb')

	for sample in Bar_Sam.values():
		outfh[sample] = pysam.AlignmentFile("%s/%s.bam" % (options.out,sample),"wb",template=bamfile)

	bamfile.close()
  
	extract_reads(options,Bar_Sam)
