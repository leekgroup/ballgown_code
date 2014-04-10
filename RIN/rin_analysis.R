## analysis for RIN results in ballgown manuscript

library(ballgown)
load('geuvadisbg.rda')

# subset only to unique individuals (noted in the qcstats file & in pData)
gbg_small = subset(geuvadisbg, "UseThisDup==1", genomesubset=FALSE) # a few min

# subset this to highly-expressed transcripts
# lots of code in this next block comes from the subset method
fpkmmeans = rowMeans(texpr(gbg_small))
hiexpr_index = which(fpkmmeans>0.1)
trans = texpr(gbg_small, 'all')[hiexpr_index,]
length(hiexpr_index) #43622 -- number of transcripts with FPKM>0.1
thetx = trans$t_id
inttmp = split(indexes(gbg_small)$i2t$i_id, indexes(gbg_small)$i2t$t_id)
theint = as.numeric(unique(unlist(inttmp[names(inttmp) %in% thetx])))
intron = subset(data(gbg_small)$intron, i_id %in% theint)
extmp = split(indexes(gbg_small)$e2t$e_id, indexes(gbg_small)$e2t$t_id)
theex = as.numeric(unique(unlist(extmp[names(extmp) %in% thetx])))
exon = subset(data(gbg_small)$exon, e_id %in% theex)
e2t = subset(indexes(gbg_small)$e2t, t_id %in% thetx)
i2t = subset(indexes(gbg_small)$i2t, t_id %in% thetx)
t2g = subset(indexes(gbg_small)$t2g, t_id %in% thetx)
introngr = structure(gbg_small)$intron[elementMetadata(structure(gbg_small)$intron)$id %in% theint]
exongr = structure(gbg_small)$exon[elementMetadata(structure(gbg_small)$exon)$id %in% theex]
grltxids = substr(names(structure(gbg_small)$trans), 3, nchar(names(structure(gbg_small)$trans)))
transgrl = structure(gbg_small)$trans[grltxids %in% thetx]
gbg_nodup_nolow = new("ballgown", data=list(intron=intron, exon=exon, trans=trans), 
    indexes=list(e2t=e2t, i2t=i2t, t2g=t2g, bamfiles=indexes(gbg_small)$bamfiles, pData=indexes(gbg_small)$pData), 
    structure=list(intron=introngr, exon=exongr, trans=transgrl), 
    dirs=dirs(gbg_small), mergedDate=mergedDate(gbg_small))

# determine which transcripts have expression most affected by RIN 
# (high expression only)
rin_results_hiexpr = stattest(gbg_nodup_nolow, feature="transcript",
    meas="FPKM", timecourse=TRUE, covariate="RIN", adjustvars="population")

sum(rin_results_hiexpr$qval<0.05) # 19,118 significant (q<0.05)

gbg = gbg_nodup_nolow #alias for quicker typing

results_sorted = rin_results_hiexpr[order(rin_results_hiexpr$pval),]


# the library adjustment term (per-sample, sum of FPKMs up to 75th percentile)
lib_adj = apply(as.matrix(texpr(gbg,"FPKM")), 2, function(x){
    q3 = quantile(x, 0.75)
    sum(x[x<q3])
})

# function to plot RIN vs. expression + fitted lines (per population, assuming average library size)
plotfitted = function(results, rowInd, bgobj, lib_adj, 
    legloc = 'topleft', returnModel = FALSE, ...){
    require(splines)
    require(RSkittleBrewer)
    tid = as.numeric(as.character(results[rowInd,]$id))
    ind = which(texpr(bgobj,'all')$t_id == tid)
    transexp = log2(texpr(bgobj,"FPKM")[ind,]+1)
    mdf = data.frame(pData(bgobj)$RIN, as.factor(pData(bgobj)$population), as.numeric(transexp), lib_adj)
    mdf = mdf[order(mdf[,1]),]
    names(mdf) = c("RIN", "pop", "expression", "lib")
    model = lm(expression ~ ns(RIN, 4) + pop + lib, data=mdf)
    plot(mdf[,1], mdf[,3], xlab="RIN", ylab="log2(transcript expression + 1)", ...)
    chr = texpr(bgobj,'all')$chr[ind]
    start = texpr(bgobj,'all')$start[ind]
    end = texpr(bgobj,'all')$end[ind]
    title(paste0("transcript ", tid, ", ", chr, ": ",start,"-",end))

    # predictions
    n=nrow(mdf)
    lib=rep(mean(lib_adj), n)
    colpal = RSkittleBrewer('wildberry') 
    newdataYRI = data.frame(RIN=mdf[,1], pop=rep("YRI", n), lib)
    newdataCEU = data.frame(RIN=mdf[,1], pop=rep("CEU", n), lib)
    newdataFIN = data.frame(RIN=mdf[,1], pop=rep("FIN", n), lib)
    newdataGBR = data.frame(RIN=mdf[,1], pop=rep("GBR", n), lib)
    newdataTSI = data.frame(RIN=mdf[,1], pop=rep("TSI", n), lib)
    lines(mdf$RIN, predict(model, newdataYRI), col=colpal[1], lwd=3)
    lines(mdf$RIN, predict(model, newdataCEU), col=colpal[2], lwd=3)
    lines(mdf$RIN, predict(model, newdataFIN), col=colpal[3], lwd=3)
    lines(mdf$RIN, predict(model, newdataGBR), col=colpal[4], lwd=3)
    lines(mdf$RIN, predict(model, newdataTSI), col=colpal[5], lwd=3)
    legend(legloc, col=colpal, lwd=3, c("YRI", "CEU", "FIN", "GBR", "TSI"))    

    if(returnModel){
        return(model)
    }
}

#### FIGURE 3, left panel
pdf('figure3_left.pdf')
    plotfitted(results_sorted, 31, gbg, lib_adj, pch=19, col="#00000050")
dev.off()

#### FIGURE 3, right panel
pdf("figure3_right.pdf")
    plotfitted(results_sorted, 2246, gbg, lib_adj, pch=19, col="#00000050")
dev.off()


# investigate transcripts where a polynomial RIN model fits better than a linear RIN model
transexp = log2(texpr(gbg, "FPKM")[1,]+1)
mdf = data.frame(pData(gbg)$RIN, as.factor(pData(gbg)$population), as.numeric(transexp), lib_adj)
names(mdf) = c("RIN", "pop", "expression", "lib")
mdf$RIN2 = (mdf$RIN)^2
mdf$RIN3 = (mdf$RIN)^3
mod = lm(expression ~ RIN + RIN2 + RIN3 + pop + lib, data=mdf, x=TRUE)
mod0 = lm(expression ~ RIN + pop + lib, data=mdf, x=TRUE)

statres_poly_or_not = stattest(gbg, mod=mod$x, mod0=mod0$x, 
    feature='transcript', meas='FPKM')

curvebetter_sort = statres_poly_or_not[order(statres_poly_or_not$pval),]
length(which(curvebetter_sort$qval < 0.05)) #1450
length(which(results_sorted$qval < 0.05)) #19,118

curvebetter_sort[which(curvebetter_sort$id == 2208),] #figure 3 left panel: q < 1e-05
curvebetter_sort[which(curvebetter_sort$id == 295456),] #figure 3 right panel: q < 1e-05


# investigate distribution of RIN effects
# (expect more positive than negative)
### get linear coefficient
library(limma)
x = model.matrix(~as.factor(pData(gbg)$population) + pData(gbg)$RIN)
y = log2(texpr(gbg)+1)
model = lmFit(y, x)
ebmodel = eBayes(model, trend=TRUE)
#### supplementary Figure 2
pdf("supp_figure2.pdf")
    hist(ebmodel$t[,6], col='gray', main='t-statistics for linear RIN coefficients', xlab='t-statistics', breaks=50)
    abline(v=0, col='red', lwd=2)
dev.off()


# investigate average coverage (vs. FPKM) as expression measurement
rrcov_hiexpr = stattest(gbg, feature="transcript", meas="cov", 
    timecourse=TRUE, covariate="RIN", adjustvars="population")
nrow(rrcov_hiexpr)
nrow(rin_results_hiexpr)
sum(rrcov_hiexpr$id != rin_results_hiexpr$id) #0, as expected (sanity check)

#### Figure 6d
pdf("figure6d.pdf")
    fpkmrank = rank(rin_results_hiexpr$pval)
    covrank = rank(rrcov_hiexpr$pval)
    set.seed(12390)
    # downsampling, for readability
    inds = sample(1:length(fpkmrank), 2000)
    plot(fpkmrank[inds], covrank[inds], xlab="FPKM rank", ylab="Average coverage rank", pch=19, cex=0.7)
dev.off()

