## simulation results for ballgown manuscript

library(devtools)
install_github('ballgown', 'alyssafrazee')
library(ballgown)

fpkm_sim_dir = '~/hopkins/research/_ballgown/ballgown_paper/simulation_results/directFPKM')
annotation = 'genes-clean.gtf' ### add path to genes-clean.gtf
nb_sim_dir = '~/hopkins/research/_ballgown/ballgown_paper/simulation_results/NB'

#### FPKM simulation
setwd(fpkm_sim_dir)
# cuffdiff
cuffdiff = read.table('cuffdiff/isoform_exp.diff', sep='\t', header=TRUE)
cuffok = subset(cuffdiff, status=='OK')

# ballgown
bg = ballgown(dataDir='ballgown', samplePattern='sample')
pData(bg) = data.frame(id=sampleNames(bg), group=rep(c(1,0), each=10))
statres = stattest(bg, feature='transcript', meas='FPKM', libadjust=TRUE, covariate='group', getFC=TRUE)
statres_cov = stattest(bg, feature='transcript', meas='cov', libadjust=TRUE, covariate='group', getFC=TRUE)

#### histograms for paper figures
hiexpr = which(rowMeans(texpr(bg)) > 1)
cuffp_hiexp = cuffdiff$p_value[match(texpr(bg, 'all')$t_name, cuffdiff$test_id)][hiexpr]

bhist = function(z, add=FALSE, breaks=20,
                 col="black", fill="orange", alpha=0.5,
                 xlim=c(-0.01,1.01),ylim=NULL,...){
    h = hist(z, breaks=breaks, plot=FALSE)
    if(is.null(ylim)) ylim = c(0,max(h$counts))
    if(!add){plot(0,0, type="n", xlim=xlim,ylim=ylim,...)}
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

#### FIGURE 2C
pdf("figure2c.pdf")
    bhist(statres$pval[hiexpr], fill='dodgerblue', alpha=0.85,
        xlab="p-values", ylab='Frequency', ylim=c(0, 400),
        main="Simulated dataset")
    bhist(cuffp_hiexp, fill='orange', alpha=0.85, add=TRUE)
dev.off()


#### FIGURE 6B (p-value histogram for coverage)
hist(statres_cov$pval, xlab="p-values", col="gray", breaks=30, main="")

## accuracy plots from simulations
trulyDE = read.table('de_ids.txt')
simResults = assessSim(bg, statres, annotation=annotation, chr='22', 
    trulyDEids=trulyDE[,1], cuffdiffFile='cuffdiff/isoform_exp.diff', 
    qcut=seq(0,0.99, by=0.01), UCSC=FALSE, ret=TRUE, nClosest=3,
    limmaresults = NULL)

simResultsCov = assessSim(bg, statres_cov, annotation=annotation, chr='22',
    trulyDEids=trulyDE[,1], cuffdiffFile='cuffdiff/isoform_exp.diff', 
    qcut=seq(0,0.99, by=0.01), UCSC=FALSE, ret=TRUE, nClosest=3,
    limmaresults = NULL)

#isDE matches statres$id
bgres_more = data.frame(statres, isDE=simResults$isDE, 
    cuffID=texpr(bg,'all')$t_name[match(statres$id, texpr(bg,'all')$t_id)])
cuffdiff$isDE = bgres_more$isDE[match(cuffdiff$test_id, bgres_more$cuffID)]
x = cuffdiff$isDE[order(cuffdiff$p_value)]
### of top 100 cuffdiff transcripts, how many are truly DE? (reported in manuscript)
sum(x[1:100]) #63

#### FIGURE 2D
pdf("figure2d.pdf")
    plot(cumsum(as.numeric(x)), type='l', col='orange', lwd=3, xlab='p-value rank', ylab='number of DE transcripts discovered')
    bgx = simResults$isDE[order(statres$pval)]
    lines(cumsum(as.numeric(bgx)), col='dodgerblue', lwd=3)
    legend("topleft", lwd=c(3,3), col=c('dodgerblue', 'orange'), c('Ballgown linear models', 'Cuffdiff 2'))
dev.off()

#### FIGURE 6C
pdf("figure6c.pdf")
    plot(cumsum(as.numeric(x)), type='l', col='orange', lwd=3, xlab='p-value rank', ylab='number of DE transcripts discovered')
    lines(cumsum(as.numeric(bgx)), col='dodgerblue', lwd=3)
    bgxc = simResultsCov$isDE[order(statres_cov$pval)]
    lines(cumsum(as.numeric(bgxc)), col='purple3', lwd=3)
    legend("topleft", lwd=c(3,3), col=c('dodgerblue', 'purple3', 'orange'), c('Ballgown linear models (FPKM)', 'Ballgown linear models (cov)', 'Cuffdiff 2'))
dev.off()


### of top 100 ballgown transcripts, how many are truly DE? 
sum(bgx[1:100]) #78
sum(bgxc[1:100]) #82, using coverage instead of FPKM

### compare ranks of cov/FPKM
covrank = rank(statres_cov$pval)
fpkmrank = rank(statres$pval)
#### FIGURE 6A
pdf("figure6a.pdf")
    plot(fpkmrank, covrank, xlab="FPKM rank", ylab="cov rank",pch=19)
dev.off()






#### NB simulation
setwd(nb_sim_dir)
cuffdiffnb = read.table('cuffdiff/isoform_exp.diff', sep='\t', header=TRUE)
cuffoknb = subset(cuffdiffnb, status=='OK')

bgnb = ballgown(dataDir='ballgown', samplePattern='sample')
pData(bgnb) = data.frame(id=sampleNames(bgnb), group=rep(c(1,0), each=10))
statresnb = stattest(bgnb, feature='transcript', meas='FPKM', libadjust=TRUE, covariate='group')

trulyDEnb = read.table('de_ids.txt')
simResultsnb = assessSim(bgnb, statresnb, annotation=annotation, chr='22', 
    trulyDEids=trulyDEnb[,1], cuffdiffFile='isoform_exp.diff', 
    qcut=seq(0,0.99, by=0.01), UCSC=FALSE, ret=TRUE, nClosest=3)

bgresnb_more = data.frame(statresnb, isDE=simResultsnb$isDE, 
    cuffID=texpr(bgnb,'all')$t_name[match(statresnb$id, texpr(bgnb,'all')$t_id)])
cuffdiffnb$isDE = bgresnb_more$isDE[match(cuffdiffnb$test_id, bgresnb_more$cuffID)]
x = cuffdiffnb$isDE[order(cuffdiffnb$p_value)]
### of top 100 cuffdiff transcripts, how many are truly DE?
sum(x[1:100]) #98

#### SUPPLEMENTARY FIGURE 1
pdf("suppfigure1.pdf")
    # (a) p-value histograms
    hiexpr = which(rowMeans(texpr(bgnb)) > 1)
    par(mfrow=c(1,2))
    bhist(statresnb$pval[hiexpr], fill='dodgerblue', alpha=0.85,
        xlab="p-values", ylab='Frequency', main="")
    cuffreorder = cuffdiffnb[match(texpr(bgnb, 'all')$t_name, cuffdiffnb$test_id),]
    cuffreorder$hiexpr = ifelse(1:nrow(cuffreorder) %in% hiexpr, "yes","no")
    cuffp_hiexp = cuffreorder$p_value[cuffreorder$status=="OK" & cuffreorder$hiexpr=="yes"]
    bhist(cuffp_hiexp, fill='orange', alpha=0.85, add=TRUE)

    # (b) rank plot
    plot(cumsum(as.numeric(x)), type='l', col='orange', lwd=3, xlab='p-value rank', ylab='number of DE transcripts discovered')
    bgx = simResultsnb$isDE[order(statresnb$pval)]
    lines(cumsum(as.numeric(bgx)), col='dodgerblue', lwd=3)
    legend("topleft", lwd=c(3,3), col=c('dodgerblue', 'orange'), c('Ballgown linear models', 'Cuffdiff 2'))
dev.off()

### of top 100 ballgown transcripts, how many are truly DE? 
sum(bgx[1:100]) #84


