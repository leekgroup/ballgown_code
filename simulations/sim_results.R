## simulation results for ballgown manuscript

library(ballgown)
library(devtools)
install_github('alyssafrazee/usefulstuff')
library(usefulstuff)

annotation = '../genes-clean.gtf' ### add path to genes-clean.gtf

#### FPKM simulation
setwd('FPKM')
# cuffdiff
cuffdiff = read.table('cuffdiff/isoform_exp.diff', sep='\t', header=TRUE)
cuffok = subset(cuffdiff, status=='OK')

# ballgown
bg = ballgown(dataDir='ballgown', samplePattern='sample')
pData(bg) = data.frame(id=sampleNames(bg), group=rep(c(1,0), each=10))
statres = stattest(bg, feature='transcript', meas='FPKM', 
    covariate='group', getFC=TRUE)
statres_cov = stattest(bg, feature='transcript', meas='cov', 
    covariate='group', getFC=TRUE)

hiexpr = which(rowMeans(texpr(bg)) > 1)
cuffp_hiexp = cuffdiff$p_value[match(texpr(bg, 'all')$t_name, cuffdiff$test_id)][hiexpr]


#### SUPPLEMENTARY FIGURE 7b
pdf("suppfig7b.pdf")
    hist(statres_cov$pval[hiexpr], col='gray',
        xlab="p-values", ylab='Frequency', main='', breaks=30)
dev.off()

## accuracy plots from simulations
trulyDE = read.table('de_ids.txt')
simResults = ballgown:::assessSim(bg, statres, 
    annotation=annotation, chr='22', 
    trulyDEids=trulyDE[,1], cuffdiffFile='cuffdiff/isoform_exp.diff', 
    qcut=seq(0,0.99, by=0.01), UCSC=FALSE, ret=TRUE, nClosest=3,
    limmaresults = NULL)

simResultsCov = ballgown:::assessSim(bg, statres_cov, 
    annotation=annotation, chr='22',
    trulyDEids=trulyDE[,1], cuffdiffFile='cuffdiff/isoform_exp.diff', 
    qcut=seq(0,0.99, by=0.01), UCSC=FALSE, ret=TRUE, nClosest=3,
    limmaresults = NULL)

#isDE matches statres$id
bgres_more = data.frame(statres, isDE=simResults$isDE, 
    cuffID=texpr(bg,'all')$t_name[match(statres$id, texpr(bg,'all')$t_id)])
cuffdiff$isDE = bgres_more$isDE[match(cuffdiff$test_id, bgres_more$cuffID)]
x = cuffdiff$isDE[order(cuffdiff$p_value)]
### of top 100 cuffdiff transcripts, how many are truly DE? (reported in manuscript)
sum(x[1:100]) #85

bgx = simResults$isDE[order(statres$pval)]
bgxc = simResultsCov$isDE[order(statres_cov$pval)]

# #### FIGURE 2D ### outdated
# pdf("figure2d.pdf")
#     plot(cumsum(as.numeric(x)), type='l', col='orange', lwd=3, xlab='p-value rank', ylab='number of DE transcripts discovered')
#     lines(cumsum(as.numeric(bgx)), col='dodgerblue', lwd=3)
#     legend("topleft", lwd=c(3,3), col=c('dodgerblue', 'orange'), c('Ballgown linear models', 'Cuffdiff 2'))
# dev.off()

# #### FIGURE 6C
# pdf("figure6c.pdf")
#     plot(cumsum(as.numeric(x)), type='l', col='orange', lwd=3, xlab='p-value rank', ylab='number of DE transcripts discovered')
#     lines(cumsum(as.numeric(bgx)), col='dodgerblue', lwd=3)
#     lines(cumsum(as.numeric(bgxc)), col='purple3', lwd=3)
#     legend("topleft", lwd=c(3,3), col=c('dodgerblue', 'purple3', 'orange'), c('Ballgown linear models (FPKM)', 'Ballgown linear models (cov)', 'Cuffdiff 2'))
# dev.off()


### of top 100 ballgown transcripts, how many are truly DE? 
sum(bgx[1:100]) #81
sum(bgxc[1:100]) #81

### compare ranks of cov/FPKM
covrank = rank(statres_cov$pval)
fpkmrank = rank(statres$pval)
### supplementary Figure 7a
plot(fpkmrank, covrank, xlab="FPKM rank", ylab="cov rank",pch=19)

### roc curve: Supplementary Figure 6b
pdf('suppfig6b.pdf')
plot(1-simResults$ballgownspec, simResults$ballgownsens, 
    col = "dodgerblue", type = "l", 
    xlab = "False positive rate", ylab = "True positive rate", 
        lwd = 2, ylim = c(0, 1))
    lines(1 - simResults$cuffdiffspec, simResults$cuffdiffsens, 
        col = "orange", lwd = 2)
    legend("bottomright", lty = c(1, 1), lwd = c(2, 2), 
        col = c("dodgerblue", "orange"), 
        c("Linear models", "Cuffdiff 2"))
dev.off()

### histogram: Supplementary Figure 6a
pdf("suppfigure6a.pdf")
    hiexpr = which(rowMeans(texpr(bg)) > 1)
    bhist(statres$pval[hiexpr], fill='dodgerblue', alpha=0.85,
        xlab="p-values", ylab='Frequency', main="")
    cuffreorder = cuffdiff[match(texpr(bg, 'all')$t_name, cuffdiff$test_id),]
    cuffreorder$hiexpr = ifelse(1:nrow(cuffreorder) %in% hiexpr, "yes","no")
    cuffp_hiexp = cuffreorder$p_value[cuffreorder$status=="OK" & cuffreorder$hiexpr=="yes"]
    bhist(cuffp_hiexp, fill='orange', alpha=0.85, add=TRUE)
dev.off()


#### NB simulation
setwd('../NB')
cuffdiffnb = read.table('cuffdiff/isoform_exp.diff', sep='\t', header=TRUE)
cuffoknb = subset(cuffdiffnb, status=='OK')

bgnb = ballgown(dataDir='ballgown', samplePattern='sample')
pData(bgnb) = data.frame(id=sampleNames(bgnb), group=rep(c(1,0), each=10))
statresnb = stattest(bgnb, feature='transcript', meas='FPKM', covariate='group')

trulyDEnb = read.table('de_ids.txt')
simResultsnb = ballgown:::assessSim(bgnb, statresnb, annotation=annotation, chr='22', 
    trulyDEids=trulyDEnb[,1], cuffdiffFile='cuffdiff/isoform_exp.diff', 
    qcut=seq(0,0.99, by=0.01), UCSC=FALSE, ret=TRUE, nClosest=3)

bgresnb_more = data.frame(statresnb, isDE=simResultsnb$isDE, 
    cuffID=texpr(bgnb,'all')$t_name[match(statresnb$id, texpr(bgnb,'all')$t_id)])
cuffdiffnb$isDE = bgresnb_more$isDE[match(cuffdiffnb$test_id, bgresnb_more$cuffID)]
x = cuffdiffnb$isDE[order(cuffdiffnb$p_value)]
### of top 100 cuffdiff transcripts, how many are truly DE?
sum(x[1:100]) #96

#### SUPPLEMENTARY FIGURE 6d
pdf('suppfig6d.pdf')
plot(1-simResultsnb$ballgownspec, simResultsnb$ballgownsens, 
    col = "dodgerblue", type = "l", 
    xlab = "False positive rate", ylab = "True positive rate", 
        lwd = 2, ylim = c(0, 1))
    lines(1 - simResultsnb$cuffdiffspec, simResultsnb$cuffdiffsens, 
        col = "orange", lwd = 2)
    legend("bottomright", lty = c(1, 1), lwd = c(2, 2), 
        col = c("dodgerblue", "orange"), 
        c("Linear models", "Cuffdiff 2"))
dev.off()


#### SUPPLEMENTARY FIGURE 6c
pdf("suppfigure6c.pdf")
    hiexpr = which(rowMeans(texpr(bgnb)) > 1)
    bhist(statresnb$pval[hiexpr], fill='dodgerblue', alpha=0.85,
        xlab="p-values", ylab='Frequency', main="")
    cuffreorder = cuffdiffnb[match(texpr(bgnb, 'all')$t_name, cuffdiffnb$test_id),]
    cuffreorder$hiexpr = ifelse(1:nrow(cuffreorder) %in% hiexpr, "yes","no")
    cuffp_hiexp = cuffreorder$p_value[cuffreorder$status=="OK" & cuffreorder$hiexpr=="yes"]
    bhist(cuffp_hiexp, fill='orange', alpha=0.85, add=TRUE)

    # # (b) rank plot ###outdated
    # plot(cumsum(as.numeric(x)), type='l', col='orange', lwd=3, xlab='p-value rank', ylab='number of DE transcripts discovered')
    # bgx = simResultsnb$isDE[order(statresnb$pval)]
    # lines(cumsum(as.numeric(bgx)), col='dodgerblue', lwd=3)
    # legend("topleft", lwd=c(3,3), col=c('dodgerblue', 'orange'), c('Ballgown linear models', 'Cuffdiff 2'))
dev.off()

### of top 100 ballgown transcripts, how many are truly DE? 
sum(bgx[1:100]) #91


