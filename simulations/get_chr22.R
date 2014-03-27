# create 'ensembl_chr22.fa' 
# first need to download: ftp://ftp.ensembl.org/pub/release-74/fasta/homo_sapiens/cdna/Homo_sapiens.GRCh37.74.cdna.all.fa.gz
# then need to unzip.

library(Biostrings)

transcripts = readDNAStringSet('Homo_sapiens.GRCh37.74.cdna.all.fa')
length(transcripts) #180,253
txnames = names(transcripts)
txtype1 = strsplit(txnames, split=' ')
txtype = unlist(lapply(txtype1, function(x) x[2]))
table(txtype)
sum(txtype=='cdna:known') #129091

chromosome = unlist(lapply(txtype1, function(x) x[3]))
chromosome = strsplit(chromosome, split=':')
strand = unlist(lapply(chromosome, function(x) as.numeric(x[6])))
chromosome = unlist(lapply(chromosome, function(x) x[3]))
sum(chromosome=='22') #3747

chr22known = transcripts[txtype=='cdna:known' & chromosome=='22']
writeXStringSet(chr22known, file='ensembl_chr22.fa')
