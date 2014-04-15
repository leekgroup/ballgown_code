###########################################
## generate simulated reads for pipeline ##
###########################################

# parse command-line arguments:
provided = commandArgs(trailingOnly=TRUE)
fasta = provided[1]
UCSC = provided[2]=="1" #evaluates to TRUE if UCSC=1
nsamples = as.numeric(provided[3])
foldchange = as.numeric(provided[4])
foldername = provided[5]
percentde = as.numeric(provided[6])
randomde = provided[7]=="1"
threshold = as.numeric(provided[8])
minlibsize = as.numeric(provided[9])
maxlibsize = as.numeric(provided[10])
p0 = as.numeric(provided[11])
mu = as.numeric(provided[12])
ratio = as.numeric(provided[13])


# load libs
library(devtools)
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
nde = round(percentde * ntranscripts)

fc = rep(1,ntranscripts)
index = sample(1:ntranscripts,size=nde,replace=FALSE) # the de indexes
fc[index] = foldchange


nreads = matrix(NA, nrow=ntranscripts, ncol=nsamples)
for(i in 1:ntranscripts){
    coinflip = rbinom(1, prob=0.5, size=1)
    coinflipvec = rep(c(coinflip, 1-coinflip), each=nsamples/2)
    muvec = ifelse(coinflipvec==0, mu, mu*fc[i])
    sizevec = muvec*ratio
    nreads[i,]= rnbinom(nsamples,mu=muvec,size=sizevec)
}

write.table(ids[index], file=paste0(foldername,'/de_ids.txt'), quote=FALSE, row.names=FALSE, col.names=FALSE)
save(nreads, file=paste0(foldername, '/nreads.rda'))

# generate reads!
outdir = paste0(foldername, '/data/')
system(paste('mkdir -p', outdir))
simulate_experiment_countmat(fasta=fasta, readmat=nreads, outdir=outdir)
