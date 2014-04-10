# make GEUVADIS ballgown object

library(ballgown)

# directory where tablemaker output was written
dataDir = '/amber2/scratch/jleek/GEUVADIS/Ballgown/'

# directory where BAM files (tophat output) were written
bamDir = '/amber2/scratch/jleek/GEUVADIS/BAM/'
bamfiles = sapply(sampnames, function(x){
    paste0(bamDir, x, '_accepted_hits.bam')
}, USE.NAMES=FALSE)

# make phenotype table:
info = read.table('pop_data_annot_whole.txt')
pheno = read.table("GD667.QCstats.masterfile.txt", sep='\t', header=TRUE)
m = read.delim("pop_data_withuniqueid.txt", as.is=TRUE)
sampnames = list.files(dataDir, pattern = 'H|N')
pd = data.frame(dirname=info$V2, population=info$V3)
pd = pd[match(sampnames, pd$dirname),]
pd$dirname = as.character(pd$dirname)
pd$IndividualID = ballgown:::ss(pd$dirname, "_", 1)
pd$SampleID = m$sample_id[match(pd$dirname, m$folder_id)]
pd$UseThisDup = pheno$UseThisDuplicate[match(pd$SampleID, rownames(pheno))]
pd$RIN = pheno$RIN[match(pd$SampleID, rownames(pheno))]

# create ballgown object:
geuvadisbg = ballgown(dataDir = dataDir, samplePattern = 'H|N', 
    bamfiles = bamfiles, pData = pd)
save(geuvadisbg, file='geuvadisbg.rda')

