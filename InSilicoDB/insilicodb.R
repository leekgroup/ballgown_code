## code for analyzing InSilico DB datasets

library(sqldf)
library(reshape2)
library(ballgown)
library(cummeRbund)
library(devtools)
install_github('alyssafrazee/usefulstuff')
library(usefulstuff)

########### STUDY 1
## GSE36552
#"Tracing pluripotency of human early embryos and embryonic stem cells by single cell RNA-seq"
#http://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE36552

# long code needed here because cummeRbund fails on this database
db = dbConnect(SQLite(), dbname="GSE36552GPL11154_DGE_04ec2b6a46a9ddb8ef2083b9d8ba4e3c.db")
reptable = dbReadTable(db, 'isoformReplicateData')
repdata = acast(reptable, formula=isoform_id ~ rep_name, value.var='fpkm')
#repdata = acast(reptable, formula=isoform_id ~ rep_name, value='fpkm') # takes several minutes
numreps = table(reptable$sample_name)
# which samples have the most reps?
numreps[order(numreps, decreasing=TRUE)][1:2]
indexblast = which(grepl("'human preimplantation blastomere'", colnames(repdata)))
indexembryo = which(grepl("'human embryonic stem cell'", colnames(repdata)))
rdata = repdata[,c(indexblast,indexembryo)]
grp = as.factor(grepl("'human embryonic stem cell'", colnames(rdata)))
rdata = as.matrix(rdata)
class(rdata) = "matrix"
difftable = dbReadTable(db, 'isoformExpDiffData')
index = which(difftable$sample_1=="'human preimplantation blastomere'" & difftable$sample_2=="'human embryonic stem cell'")
dtable = difftable[index,]

# ballgown results:
rownames(rdata) = rownames(repdata)
statres = stattest(gowntable=rdata, pData = data.frame(group=grp), 
        feature="transcript", covariate="group") ##matches dtable


## make p-value histograms
hiexpr = which(rowMeans(rdata) > 1)
cuffp_hiexp = dtable$p_value[match(rownames(rdata), dtable$isoform_id)][hiexpr]

## supplementary figure 5d
pdf("celltype_oldcd.pdf")
    bhist(statres$pval[hiexpr], fill='dodgerblue', alpha=0.6,
        xlab="p-values", ylab='Frequency', 
        main="Cell type comparison, Cuffdiff 2.0.2")
    bhist(cuffp_hiexp, fill='orange', alpha=0.6, add=TRUE)
    legend('topright', col=c('dodgerblue', 'orange'), pch=c(15,15), 
        c('Ballgown', 'Cuffdiff'))
dev.off()

# numbers for manuscript
statq_new = p.adjust(statres$pval[hiexpr],'fdr')
length(which(statq_new < 0.05)) #6964
cuffq_new = p.adjust(cuffp_hiexp, 'fdr')
length(which(cuffq_new < 0.05)) #0
length(hiexpr) #12469

###########################################

###### STUDY 2
# A high dimensional deep sequencing study of non-small cell lung adenocarcinoma in never-smoker Korean females
# http://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE37764

# cummeRbund works on this dataset
gse37764 = readCufflinks(dbFile="GSE37764GPL10999_DGE_a9dc2c94672e4a51c036c76be9508164.db")
iso = isoforms(gse37764)
ddata = diffData(isoforms(gse37764))

# ballgown
library(reshape)

getInsdbTable = function(dbFile, feature="isoform", meas="fpkm"){
    feature = match.arg(feature, c("isoform", "gene", "CDS", "TSS"))
    meas = match.arg(meas, c("fpkm", "raw_frags", "internal_scaled_frags", "external_scaled_frags"))
    cuff = readCufflinks(dbFile=dbFile)
    if(feature == "isoform"){
        data_tmp = cast(repFpkm(isoforms(cuff)), isoform_id ~ rep_name, value=meas)
    }else if(feature == "gene"){
        data_tmp = cast(repFpkm(genes(cuff)), gene_id ~ rep_name, value=meas)
    }else if(feature == "CDS"){
        data_tmp = cast(repFpkm(CDS(cuff)), CDS_id ~ rep_name, value=meas)
    }else{
        data_tmp = cast(repFpkm(TSS(cuff)), TSS_id ~ rep_name, value=meas)
    }
    final_data = as.matrix(data_tmp[,-1])
    rownames(final_data) = data_tmp[,1]
    colnames(final_data) = names(data_tmp)[-1]
    return(final_data)
}

bg_table = getInsdbTable("GSE37764GPL10999_DGE_a9dc2c94672e4a51c036c76be9508164.db")
hiexpr = which(rowMeans(bg_table)>1)
pData = data.frame(status = as.numeric(grepl('tumor', colnames(bg_table))))
statres = stattest(gowntable=bg_table, pData=pData, 
    feature="transcript", covariate="status") ##matches bg_table

## numbers for manuscript text:
length(hiexpr)  #4454
cuffp_hiexp = ddata$p_value[match(rownames(bg_table), ddata$isoform_id)][hiexpr]
cuffq_new = p.adjust(cuffp_hiexp, 'fdr')
length(which(cuffq_new < 0.05)) #1
statq_new = p.adjust(statres$pval[hiexpr], 'fdr')
length(which(statq_new < 0.05)) #774 

#### supplementary figure 5b
cuffp_hiexp = ddata$p_value[match(rownames(bg_table), ddata$isoform_id)][hiexpr]
pdf("cancer_oldcd.pdf")
    bhist(statres$pval[hiexpr], fill='dodgerblue', alpha=0.6,
        xlab="p-values", ylab='Frequency', main="Tumor vs. control, Cuffdiff 2.0.2")
    bhist(cuffp_hiexp, fill='orange', alpha=0.6, add=TRUE)
    legend(0.7, 1360, col=c('dodgerblue', 'orange'), pch=c(15,15), 
        c('Ballgown', 'Cuffdiff'))
dev.off()

