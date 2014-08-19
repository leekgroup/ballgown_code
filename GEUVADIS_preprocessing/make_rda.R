## code for creating GEUVADIS ballgown objects

library(ballgown) #need version 0.99.2 or higher
system('mkdir -p Ballgown/small_objects') #assume output stored in Ballgown folder

## make phenotype table:
dataDir = 'Ballgown/'
sampnames = list.files(dataDir, pattern = 'H|N')
info = read.table('pop_data_annot_whole.txt')
pheno = read.table("GD667.QCstats.masterfile.txt", sep='\t', header=TRUE)
m = read.delim("pop_data_withuniqueid.txt", as.is=TRUE)
pd = data.frame(dirname=info$V2, population=info$V3)
pd = pd[match(sampnames, pd$dirname),]
pd$dirname = as.character(pd$dirname)
pd$IndividualID = ballgown:::ss(pd$dirname, "_", 1)
pd$SampleID = m$sample_id[match(pd$dirname, m$folder_id)]
pd$UseThisDup = pheno$UseThisDuplicate[match(pd$SampleID, rownames(pheno))]
pd$RIN = pheno$RIN[match(pd$SampleID, rownames(pheno))]

## make various ballgown objects
## this takes several hours. (compressing this much is quite slow)
fpkm = ballgown(dataDir=dataDir, samplePattern='H|N', pData=pd, meas='FPKM')
save(fpkm, file='Ballgown/small_objects/fpkm.rda', compress='xz')

cov = ballgown(dataDir=dataDir, samplePattern='H|N', pData=pd, meas='cov')
save(cov, file='Ballgown/small_objects/cov.rda', compress='xz')

rcount = ballgown(dataDir=dataDir, samplePattern='H|N', pData=pd, meas='rcount')
save(rcount, file='Ballgown/small_objects/rcount.rda', compress='xz')

ucount = ballgown(dataDir=dataDir, samplePattern='H|N', pData=pd, meas='ucount')
save(ucount, file='Ballgown/small_objects/ucount.rda', compress='xz')

mrcount = ballgown(dataDir=dataDir, samplePattern='H|N', pData=pd, meas='mrcount')
save(mrcount, file='Ballgown/small_objects/mrcount.rda', compress='xz')

cov_sd = ballgown(dataDir=dataDir, samplePattern='H|N', pData=pd, meas='cov_sd')
save(cov, file='Ballgown/small_objects/cov_sd.rda', compress='xz')

mcov = ballgown(dataDir=dataDir, samplePattern='H|N', pData=pd, meas='mcov')
save(mcov, file='Ballgown/small_objects/mcov.rda', compress='xz')

mcov_sd = ballgown(dataDir=dataDir, samplePattern='H|N', pData=pd, meas='mcov_sd')
save(mcov_sd, file='Ballgown/small_objects/mcov_sd.rda', compress='xz')

