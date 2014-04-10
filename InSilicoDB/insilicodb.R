## code for analyzing InSilico DB datasets

library(sqldf)
library(reshape)
library(ballgown)
library(cummeRbund)

########### STUDY 1
## GSE36552
#"Tracing pluripotency of human early embryos and embryonic stem cells by single cell RNA-seq"
#http://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE36552

# long code needed here because cummeRbund fails on this database
db = dbConnect(SQLite(), dbname="GSE36552GPL11154_DGE_04ec2b6a46a9ddb8ef2083b9d8ba4e3c.db")
reptable = dbReadTable(db, 'isoformReplicateData')
repdata = cast(reptable, formula=isoform_id ~ rep_name, value='fpkm') # takes several minutes
numreps = table(reptable$sample_name)
# which samples have the most reps?
numreps[order(numreps, decreasing=TRUE)][1:2]
indexblast = which(grepl("'human preimplantation blastomere'",names(repdata)))
indexembryo = which(grepl("'human embryonic stem cell'",names(repdata)))
rdata = repdata[,c(indexblast,indexembryo)]
grp = as.factor(grepl("'human embryonic stem cell'",names(rdata)))
rdata = as.matrix(rdata)
class(rdata) = "matrix"
difftable = dbReadTable(db, 'isoformExpDiffData')
index = which(difftable$sample_1=="'human preimplantation blastomere'" & difftable$sample_2=="'human embryonic stem cell'")
dtable = difftable[index,]

# ballgown results:
rownames(rdata) = repdata$isoform_id
statres = stattest_table(rdata, pData = data.frame(group=grp), 
    feature="transcript", covariate="group") ##matches dtable


## make p-value histograms
hiexpr = which(rowMeans(rdata) > 1)
cuffp_hiexp = dtable$p_value[match(rownames(rdata), dtable$isoform_id)][hiexpr]

bhist = function(z, add=FALSE, breaks=20,
                 col="black", fill="orange", alpha=0.5,
                 xlim=c(-0.01,1.01),...){
    h = hist(z, breaks=breaks, plot=FALSE)
    ylim = c(0,max(h$counts))
    if(!add){plot(0,0, type="n", xlim=xlim, ylim=ylim,...)}
    hb = rep(h$breaks, each=2)[-1]
    x = c(hb,0)
    y = c(rep(h$counts, each=2),0,0)
    fill=makeTransparent(fill,alpha=0.5)
    polygon(x, y, border=col, col=fill, lwd=1)
    for(i in seq_along(y)){
        lines(rep(x[i], 2), c(0, y[i]), col=col)
    }
}
  
## Transparentize colors borrowed from here http://stackoverflow.com/questions/8047668/transparent-equivalent-of-given-color
makeTransparent = function(..., alpha=0.5) {
  if(alpha<0 | alpha>1) stop("alpha must be between 0 and 1")
  alpha = floor(255*alpha)  
  newColor = col2rgb(col=unlist(list(...)), alpha=FALSE)
  .makeTransparent = function(col, alpha) {
    rgb(red=col[1], green=col[2], blue=col[3], alpha=alpha, maxColorValue=255)
  }
  newColor = apply(newColor, 2, .makeTransparent, alpha=alpha)
  return(newColor) 
}

#### FIGURE 2b:
pdf("figure2b.pdf")
    bhist(statres$pval[hiexpr], fill='dodgerblue', alpha=0.85,
        xlab="p-values", ylab='Frequency', main="Enbryonic stem cells vs. preimplantation blastomeres")
    bhist(cuffp_hiexp, fill='orange', alpha=0.85, add=TRUE)
dev.off()

# numbers for manuscript
statq_new = p.adjust(statres$pval[hiexpr],'fdr')
length(which(statq_new < 0.05)) #7236
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
bg_table = getInsdbTable("GSE37764GPL10999_DGE_a9dc2c94672e4a51c036c76be9508164.db")
hiexpr = which(rowMeans(bg_table)>1)
pData = data.frame(status = as.numeric(grepl('tumor', colnames(bg_table))))
statres = stattest_table(bg_table, pData = pData, 
    feature="transcript", covariate="status") ##matches bg_table

## numbers for manuscript text:
length(hiexpr)  #4454
cuffp_hiexp = ddata$p_value[match(rownames(bg_table), ddata$isoform_id)][hiexpr]
cuffq_new = p.adjust(cuffp_hiexp, 'fdr')
length(which(cuffq_new < 0.05)) #1
statq_new = p.adjust(statres$pval[hiexpr], 'fdr')
length(which(statq_new < 0.05)) #809 (was incorrect in original preprint)

#### FIGURE 2a
cuffp_hiexp = ddata$p_value[match(rownames(bg_table), ddata$isoform_id)][hiexpr]
pdf("~/figure2a.pdf")
    bhist(statres$pval[hiexpr], fill='dodgerblue', alpha=0.85,
        xlab="p-values", ylab='Frequency', main="Tumor vs. control")
    bhist(cuffp_hiexp, fill='orange', alpha=0.85, add=TRUE)
dev.off()

