#### geuvadis eqtl analysis

library(ballgown)
library(MatrixEQTL)
ss = function(x, pattern, slot=1,...) sapply(strsplit(x,pattern,...), "[", slot)

xx = load("geuvadisbg.rda")

## phenotype data
pd = pData(geuvadisbg)
pd$dirname = as.character(pd$dirname)
pd$IndividualID = ss(pd$dirname, "_", 1)

##  external info for which dups to keep
pheno = read.delim("GD667.QCstats.masterfile.txt", as.is=TRUE)
m = read.delim("pop_data_withuniqueid.txt",as.is=TRUE)
pd$SampleID = m$sample_id[match(pd$dirname, m$folder_id)]
pd$UseThisDup = pheno$UseThisDuplicate[match(pd$SampleID, rownames(pheno))]

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

### mean filter: only keep transcripts with FPKM>0.1
mmTrans = rowMeans(gownTransFPKM) 
keepIndex=which(mmTrans > 0.1)
gownTransFPKM2 = gownTransFPKM[keepIndex,]
gownTransMap2 = gownTransMap[keepIndex]

# log transformation
y = log2(gownTransFPKM2 + 1)
exprsPCs = prcomp(t(y))$x[,1:3]

## genotype pcs
mds = read.table("Genotypes/plink.mds", header=TRUE, as.is=TRUE)
snpPCs = mds[match(pd$IndividualID, mds$IID),]

## load SNP data
load("Genotypes/GEUVADIS_genotypeData_maf05.rda")
snp2 = snp[,pd$IndividualID]
snpMap = map

#### EQTL #####
mod = model.matrix(~exprsPCs + snpPCs$C1 + snpPCs$C2 + snpPCs$C3)
# covariates must be transposed w/ no intercept!
covs = SlicedData$new(t(mod[,-1]))

exprs = SlicedData$new(as.matrix(y))
exprs$ResliceCombined(sliceSize = 1000)

theSnps = SlicedData$new(snp2)
theSnps$ResliceCombined(sliceSize = 50000)

output_file_name = "eQTL_GEUVADIS_imputed_list_cis.txt" 
errorCovariance = numeric();

## need annotation for CIS
snpspos = snpMap[,c("name","chr","pos")]
snpspos$chr = paste0("chr", snpspos$chr)

geneRange = unlist(range(gownTransMap2))
geneRange = as.data.frame(geneRange)
geneRange$txID = rownames(gownTransFPKM2)
genepos = geneRange[,c("txID","seqnames","start","end")]
colnames(genepos)[2] = "chr"

####################### fit the model ##################################
me = Matrix_eQTL_main(snps=theSnps, gene = exprs, 
	cvrt = covs, output_file_name.cis = output_file_name,
	pvOutputThreshold = 0, pvOutputThreshold.cis = 1e-3, 
	useModel = modelLINEAR,pvalue.hist=5000,
	snpspos = snpspos, genepos = genepos, cisDist=1e6)
save(me, file="eQTL_GEUVADIS_imputed_list_cis_1e6.rda", compress=TRUE)
########################################################################

eqtl = me$cis$eqtls
eqtl$snps = as.character(eqtl$snps)
eqtl$gene = as.character(eqtl$gene)
eqtl$snpChr = snpspos$chr[match(eqtl$snps, snpspos$name)]
eqtl$snpPos = snpspos$pos[match(eqtl$snps, snpspos$name)]

eqtl$transChr = genepos$chr[match(eqtl$gene, genepos$txID)]
eqtl$transStart = genepos$start[match(eqtl$gene, genepos$txID)]
eqtl$transEnd = genepos$end[match(eqtl$gene, genepos$txID)]

eqtl$distStartMinusSnp = eqtl$transStart - eqtl$snpPos
eqtl = DataFrame(eqtl)

## annotate to Ensembl genes
gtf="Homo_sapiens.GRCh37.73_chrPrefix.gtf"
genes = getGenes(gtf, gownTransMap2,attribute = "gene_name")
names(genes) = names(gownTransMap2)
eqtl$geneSymbol = genes[match(eqtl$gene, names(genes))]

genes2 = getGenes(gtf, gownTransMap2,attribute = "gene_id")
names(genes2) = names(gownTransMap2)
eqtl$ensemblGeneID = genes2[match(eqtl$gene, names(genes2))]

sig = eqtl[eqtl$FDR < 0.05,]

save(sig, file="sig_eQTL_GEUVADIS_imputed_list_cis_1e6_annotated.rda" ,compress=TRUE)

