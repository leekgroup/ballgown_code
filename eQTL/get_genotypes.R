### code for downloading/processing GEUVADIS genotypes

library(multicore)
splitit = function(x) split(seq(along=x),x) # splits into list

## download the genotype data (only need to do once)
# system("wget ftp://ftp.ebi.ac.uk/pub/databases/microarray/data/experiment/GEUV/E-GEUV-1/genotypes/*")
## this is listed as needed data in the README, so if you have already done that, you do not need this

## MAF filter to 5%, and plink tped
files = list.files("Genotypes", pattern="PH1PH2_465", full.names=TRUE)
chr = sapply(strsplit(list.files("Genotypes", pattern="PH1PH2_465"), "\\."),"[", 2)
out = paste0("Genotypes/", chr, "_filter")

theCall = paste("vcftools --gzvcf", files, "--out", out, "--maf 0.05 --plink-tped")
mclapply(theCall, system, mc.cores=6)

## make bed to store
out = paste0("Genotypes/chr",1:22,"_filter")
theCall = paste("plink --tfile", out,"--make-bed --noweb --out", out)
mclapply(theCall, system, mc.cores=6)

# merge beds into 1 for storage
mergelist = data.frame(paste0(out, ".bed"),paste0(out, ".bim"),
	paste0(out, ".fam"))
write.table(mergelist[-1,], file="bedstomerge.txt", row.names=FALSE,
	col.names=FALSE, quote=FALSE, sep = " ")
system(paste("plink --bfile", out[1], "--merge-list bedstomerge.txt",
	"--make-bed --noweb --out GEUVADIS_maf05"))

## read in tped
fam = read.table(paste0(out[1], ".fam"), as.is=TRUE, header=FALSE)
names(fam) = c("FID","IID", "MID", "FID", "SEX","STATUS")
ids = rep(1:nrow(fam), each=2)
iIndex = splitit(ids)
names(iIndex) = fam$FID

snpList = mapList = vector("list",length(out))
for(i in seq(along=snpList)) {
	cat(".")
	snp = read.table(paste0(out[i],".tped"),header=FALSE,
		as.is=TRUE,na.strings="0")
 	# split into SNP and MAP
 	snp = snp[,-(1:4)]
 	
	gc()
 
 	map = read.table(paste0(out[i],".bim"),	header=FALSE,as.is=TRUE)
 	names(map) = c("chr","name","cm","pos","minor","major")
	
	# recode by minor allele copies
 	minorMat = matrix(rep(map$minor, each=ncol(snp)), 
 		nc = ncol(snp), nr = nrow(snp), byrow=TRUE)
 	snp = snp==minorMat
 
 	# summarize back into a matrix
 	snpMat = sapply(iIndex, function(y) rowSums(snp[,y]))
 	colnames(snpMat) = fam$IID
 	rownames(snpMat) = rownames(map) = map$name
 
 	map$inSampleMAF = rowMeans(snp, na.rm=TRUE)
 	
 	snpList[[i]] = snpMat
 	mapList[[i]] = map
}

L = sapply(snpList,nrow)
Ind = cbind(c(0,cumsum(L)[-length(L)])+1, cumsum(L))
snp = matrix(nr = sum(L), nc = ncol(snpList[[1]]))

for(i in seq(along=snpList)) {
	cat(".")
	snp[Ind[i,1]:Ind[i,2],] = snpList[[i]]
}

map = do.call("rbind", mapList)
map$chr = paste0("chr", map$chr)
rownames(snp) = rownames(map)
colnames(snp) = fam$IID

# how many snps?
nrow(snp) #7,072,917

save(map,snp, file="GEUVADIS_genotypeData_maf05.rda")

### get genotype PCs
####### these lines create plink.mds
bfile = "Genotypes/GEUVADIS_maf05"
theCall = paste("plink --bfile", bfile, 
	"--indep 50 5 1.25 --geno 0.1 --out GEUVADIS_independent --noweb")
system(theCall)

theCall = paste("plink --bfile", bfile, 
	"--noweb --make-bed --extract GEUVADIS_independent.prune.in",
	"--out GEUVADIS_independent")
system(theCall)

## IBS
system(paste("plink --bfile GEUVADIS_independent --noweb --Z-genome"))
system(paste("plink --bfile GEUVADIS_independent --read-genome plink.genome.gz",
	"--cluster --mds-plot 20  --noweb"))

