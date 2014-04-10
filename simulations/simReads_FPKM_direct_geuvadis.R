## simulate reads starting from FPKM

# parse arguments
provided = commandArgs(trailingOnly=TRUE)
fasta = provided[1]
UCSC = provided[2]=="1" #evaluates to TRUE if UCSC=1
nsamples = as.numeric(provided[3])
foldchange = as.numeric(provided[4])
foldername = provided[5]
percentde = as.numeric(provided[6])
minlibsize = as.numeric(provided[7])
maxlibsize = as.numeric(provided[8])
bgpath = provided[9]

# load libs
library(polyester)
library(ballgown)
library(Biostrings)


# load fasta file of transcripts
transcripts = readDNAStringSet(fasta)
labels = names(transcripts)
getID = function(label){
  stopifnot(UCSC)
  id = strsplit(label, split="\\|")[[1]][4]
  return(strsplit(id, split="\\.")[[1]][1])
}
if(UCSC){
  ids = sapply(labels, getID, USE.NAMES=FALSE)
}else{
  namelist = strsplit(labels, split=' ')
  ids = unlist(lapply(namelist, function(x) x[1]))
}

ntranscripts = length(transcripts)
nde = round(percentde*ntranscripts)

load(bgpath) #geuvadisbg, from shell script

texpr_nozero = texpr(geuvadisbg)[rowMeans(texpr(geuvadisbg)) > 100, ]
texpr_nozero[texpr_nozero==0] <- NA
means = rowMeans(texpr_nozero, na.rm=TRUE)
logvars = 2*log(means)+0.5  #from a logmean/logvar linear model fit
vars = exp(logvars)
p0s = rowSums(is.na(texpr_nozero))/ncol(texpr_nozero)

fc = matrix(1, nrow=ntranscripts, ncol=nsamples)
de_inds = sample(1:ntranscripts, size=nde, replace=FALSE)
for(detx in de_inds){
    which_group = sample(c(0,1), size=1)
    if(which_group == 0){
        up_inds = 1:round(nsamples/2)
    }else{
        up_inds = (round(nsamples/2)+1):nsamples
    }
    fc[detx,up_inds] = foldchange
}

write.table(ids[de_inds], file=paste0(foldername,'/de_ids.txt'), quote=FALSE, row.names=FALSE, col.names=FALSE)


meanmat = matrix(sample(means, size=ntranscripts, replace=TRUE), nrow=ntranscripts, ncol=nsamples) * fc
varmat = exp(2*log(meanmat)+0.5)
meanlogmat = log(meanmat^2 / (sqrt(varmat + meanmat^2)))
sdlogmat = sqrt(log(1 + varmat / (meanmat^2)))
sim_fpkm = matrix(rlnorm(length(meanmat), meanlog=meanlogmat, sdlog=sdlogmat), nrow=ntranscripts)
all_p0 = sample(p0s, size=ntranscripts, replace=TRUE)
for(i in 1:ntranscripts){
    is_zero = rbinom(nsamples, size=1, prob=all_p0[i])
    sim_fpkm[i,which(is_zero == 1)] <- 0
}

sim_fpk = sim_fpkm * width(transcripts)/1000
libsizes = round(runif(nsamples, min=minlibsize, max=maxlibsize))
nreads = round(sim_fpk * matrix(libsizes/1e6, nrow=ntranscripts, ncol=nsamples, byrow=TRUE))

save(nreads, file=paste0(foldername, '/nreads.rda'))

# generate reads!
outdir = paste0(foldername, '/data')
system(paste('mkdir -p', outdir))
simulate_experiment_countmat(fasta=fasta, readmat=nreads, outdir=outdir)



