### do eqtl analysis on geuvadis data
### run AFTER geuvadis_cis_eqtl-pvaluehist.R

library(MatrixEQTL)

## Install with
## library(devtools)
## install_github("ballgown","alyssafrazee"))
library(ballgown)

## Install with
## library(devtools)
## install_github("RSkittleBrewer","alyssafrazee"))
library(RSkittleBrewer)

## A useful string substitution function
## (now included in ballgown packages)
ss = function(x, pattern, slot=1,...) sapply(strsplit(x,pattern,...), "[", slot)


load("eQTL_GEUVADIS_imputed_list_cis_1e6.rda")
counts = me$cis$hist.counts
breaks = me$cis$hist.bins
ind = rep(1:100,each=50)

counts100 = tapply(counts,ind,sum)
breaks100 = c(0,tapply(breaks[2:5001],ind,max))
wsize = diff(breaks100)[1]
density100 = counts100/(wsize*sum(counts100))

pdf(file="global-check-eqtl.pdf",height=5,width=10)
par(mfrow=c(1,2),mar=c(5,5,3,3))

## Histogram

hh = list(breaks=breaks100,counts=counts100,density = density100)
class(hh) = "histogram"
plot(hh,col="grey",freq=FALSE,ylab="Density",xlab="P-value",main="",
     cex.lab=1.2,cex.axis=1.2)
abline(h=1,col="dodgerblue",lwd=3)

## QQ-plot - have to do transforms to 
## turn histograms into qq-plots here

probs = cumsum(counts/sum(counts))
plot(-log10(breaks[2:5001]),rev(-log10(1-probs)),
     xlab="Theoretical Quantiles",ylab="Empirical Quantiles",
     bg="dodgerblue",col="black",pch=21,
     cex.lab=1.2,cex.axis=1.2)
abline(c(0,1),col="grey",lwd=3)
dev.off()

## Get pi0 estimate with lambda =0.8

lambda = 0.8
ilambda = which.max(breaks >= lambda)  
1-sum(counts[ilambda:5000])/(sum(counts)*(1-lambda))



## Load the cis-eQTL from geuvadis-cis-eqtl.R

load("sig_eQTL_GEUVADIS_imputed_list_cis_1e6_annotated.rda")

dim(sig)
sig = sig[sig$FDR < 0.01, ]
length(unique(sig$snps))
length(unique(sig$gene))
gidlist=  as.list(sig$ensemblGeneID)
maxgenes = max(sapply(gidlist,length))

## Number of unique genes
length(unique(unlist(gidlist)))

## Number of unique transcripts (the matrixeqtl package refers
## to the gene expression values as genes, but we ran the analysis
## on FPKM values from transcripts so the gene column corresponds
## to transcripts. 

length(unique(unlist(as.list(sig$gene))))
      
## Find the number of annotated genes per transcript
ngpert = sapply(gidlist,length)

## Calculate the number of transcripts with no annotated gene
mean(ngpert==0)

uidmat = matrix(NA,nrow=length(gidlist),ncol=maxgenes)
for(i in 1:maxgenes){
  uidmat[,i] = paste0(sig$snps, ":",sapply(sig$ensemblGeneID,"[", i))
  cat(i)
}
## Load the cis-eQTL from CEU published by GEUVADIS

eur = read.delim("EUR373.trratio.cis.FDR5.all.rs137.txt", as.is=TRUE)
dim(eur)
length(unique(eur$SNP_ID))
length(unique(eur$PROBE_ID))
length(unique(eur$GENE_ID))


eur$snps = paste("snp", eur$CHR_SNP, eur$SNPpos, sep="_")
eur$ensemblGeneID = ss(eur$GENE_ID, "\\.")
eur$uid = paste0(eur$snps, ":", eur$ensemblGeneID)
mean(eur$uid %in% uidmat)

## Load the cis-eQTL from CEU published by GEUVADIS
yri = read.delim("YRI89.trratio.cis.FDR5.all.rs137.txt", as.is=TRUE)
dim(yri)
length(unique(yri$SNP_ID))
length(unique(yri$PROBE_ID))
length(unique(yri$GENE_ID))

yri$snps = paste("snp", yri$CHR_SNP, yri$SNPpos, sep="_")
yri$ensemblGeneID = ss(yri$GENE_ID, "\\.")

yri$uid = paste0(yri$snps, ":", yri$ensemblGeneID)
mean(yri$uid %in% uidmat)




## Load the ballgown object

load("geuvadisbg.rda")
load("sig_eQTL_GEUVADIS_imputed_list_cis_1e6_annotated.rda")
sig = sig[sig$FDR < 0.01, ]

## phenotype data
pd = pData(geuvadisbg)
pd$dirname = as.character(pd$dirname)
pd$IndividualID = ss(pd$dirname, "_", 1)

##  external files for which replicates to keep
pheno = read.delim("GD667.QCstats.masterfile.txt",as.is=TRUE)
m = read.delim("pop_data_withuniqueid.txt",as.is=TRUE)
pd$SampleID = m$sample_id[match(pd$dirname, m$folder_id)]
pd = cbind(pd,pheno[match(pd$SampleID, rownames(pheno)),])
pd$UseThisDup = pd$UseThisDupliate

pData(geuvadisbg) = pd

## drop duplicates for this
pd = pd[pd$UseThisDup == 1,]

## extract transcript data
tName = texpr(geuvadisbg,"all")$t_name

gownTrans = data(geuvadisbg)$trans
gownTransFPKM =  texpr(geuvadisbg, "FPKM")
colnames(gownTransFPKM) = ss(colnames(gownTransFPKM),"\\.",2)
gownTransFPKM = gownTransFPKM[,pd$dirname] # put in same order post-drop

gownTransMap = structure(geuvadisbg)$trans
rownames(gownTransFPKM) = names(gownTransMap) = tName

## mean filter
mmTrans = rowMeans(gownTransFPKM) 
keepIndex=which(mmTrans > 0.1)
gownTransFPKM2 = gownTransFPKM[keepIndex,]
gownTransMap2 = gownTransMap[keepIndex]

## log transform to get final expression values
finalexp = log2(gownTransFPKM2 + 1)

## Calculate principal components
exprsPCs = prcomp(t(finalexp))$x[,1:3]

## load SNP data
load("GEUVADIS_genotypeData_maf05.rda")
snp2 = snp[,pd$IndividualID]
snpMap = map

## Load genotype PCs
## genotype pcs
#mds = read.table("plink.mds",header=TRUE, as.is=TRUE)
#snpPCs = mds[match(pd$IndividualID, mds$IID),]



noanno = which(ngpert==0)
sigNoA = sig[noanno,]
t2g = indexes(geuvadisbg)$t2g

## Get transcripts that are unnanotated
transInd= which(tName %in% sigNoA$gene)

## Find one that has a reasonable number of transcripts to plot
jtmp = rep(NA,100)
for(i in 1:100){jtmp[i] = sum(t2g[transInd[i],2] == t2g[,2])}
index = which(jtmp==3)


## Get the other trancripts with the same gene
otrans = which(t2g[transInd[index],2] == t2g[,2])
length(otrans)
onames = tName[otrans]

## Second one is the DE transcript
which(otrans==transInd[index])

## Plot expression for one of the SNPs associated with this transcript
tmpGene = finalexp[which(rownames(finalexp) == tName[transInd[index]]),]
snpInd = which(rownames(snp2) %in% sigNoA$snps[which(sigNoA$gene==tName[transInd[index]])])
tmpSnp = snp2[snpInd[1],]

## Get info on the SNP gene pair

sigNoA[which((sigNoA$gene==tName[transInd[index]]) & (sigNoA$snps==rownames(snp2)[snpInd[1]])),]

## Confirm it is differentially expressed
summary(lm(tmpGene ~ as.factor(tmpSnp)))

pdf(file="eqtl-plot.pdf",height=6,width=12)
par(mfrow=c(1,2),mar=c(5,5,5,5))
wild = RSkittleBrewer('wildberry')

## Plot transcript structure
plotTranscripts("XLOC_000651",geuvadisbg,legend=FALSE,customCol=wild[c(1,2,1)],main="Chr1:64193406-64195282")

## Plot truly de transcript
boxplot(tmpGene ~ tmpSnp,border=wild[2],lwd=2,range=0,ylab="FPKM",xlab="Copies of MA for SNP Chr1:Pos 64122505")
points(jitter(tmpSnp+1),tmpGene,col="black",bg=wild[2],cex=2,pch=21)
dev.off()


sigNoA[which((sigNoA$gene==tName[transInd[index]]) & (sigNoA$snps==rownames(snp2)[snpInd[1]])),]
# DataFrame with 1 row and 14 columns
# snps           gene statistic       pvalue
# <character>    <character> <numeric>    <numeric>
#   1 snp_1_64122505 TCONS_00001509 -4.047636 6.077578e-05
# FDR        beta      snpChr    snpPos transChr
# <numeric>   <numeric> <character> <integer> <factor>
#   1 0.008593987 -0.05381211        chr1  64122505     chr1
# transStart  transEnd distStartMinusSnp      geneSymbol
# <integer> <integer>         <integer> <CharacterList>
#   1   64193406  64195282             70901                
# ensemblGeneID
# <CharacterList>