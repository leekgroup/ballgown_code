## timing results for ballgown manuscript

library(RSkittleBrewer)
colpal = RSkittleBrewer('wildberry')

# read in geuvadis times: tophat
tophat_times = read.table("tophat_times.txt", header=TRUE)
stopifnot(length(unique(tophat_times$sample)) == nrow(tophat_times)) #sanity check: make sure all the samples are unique
summary(tophat_times$time)

######## FIGURE 5a
pdf('figure5a.pdf')
    hist(tophat_times$time, breaks=30, col=colpal[1], main="TopHat runtimes (hours)", xlab="time (hours)", xlim=c(0,18))
dev.off()



# geuvadis cufflinks
cufflinks_times = read.table("cufflinks_times.txt", header=TRUE)
stopifnot(length(unique(cufflinks_times$jobid)) == nrow(cufflinks_times)) #sanity check: make sure samples are unique
stopifnot(all(cufflinks_times$status==0)) #sanity check: make sure there were no errors
summary(cufflinks_times$walltime)

######## FIGURE 5b
pdf('figure5b.pdf')
    hist(cufflinks_times$walltime, breaks=30, col=colpal[2], main="Cufflinks runtimes (hours)", xlab="time (hours)")
dev.off()



# geuvadis tablemaker
tb_times = read.table("tablemaker_times_all.txt", header=TRUE)
stopifnot(length(unique(tb_times$sample)) == nrow(tb_times)) # sanity check: make sure all sample sare there
summary(tb_times$time)

######## FIGURE 5c
pdf('figure5c.pdf')
    hist(tb_times$time, breaks=30, col=colpal[3], main="Tablemaker runtimes (hours)", xlab="time (hours)")
dev.off()



##### numerical results:
## (1) tablemaker on simulated data:
simtable = read.table('simtimes.txt', sep='\t', header=TRUE)
mean(simtable$ballgown*60) #3.2 minutes

## (2) Cuffquant on simulated data:
cqtable = read.table("cuffquant_times.txt", sep='\t', header=TRUE)
stopifnot(all(cqtable$status==0)) #sanity check for no failed jobs
mean(cqtable$walltime*60) #4.0824

## (3) TopHat on simulated data:
mean(simtable$tophat) #2.04 hours

## (4) Cufflinks on simulated data
mean(simtable$cufflinks*60) #4.85 minutes

## (5) median tablemaker time on GEUVADIS:
median(tb_times$time) #0.9661111

## (6) IQR for tablemaker times on GEUVADIS:
IQR(tb_times$time) #0.23625


