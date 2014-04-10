#!/bin/sh
## run tophat on the GEUVADIS data 

# file listing run IDs and hapmap IDs (also has populations)
# same as pop_data_withuniqueid.txt, in main folder, but no header and no sample_id column
PDATA=pop_data_annot_whole.txt

# GTF file (align reads to transcriptome first)
ANNOTATIONPATH=/amber2/scratch/jleek/iGenomes-index
GTF=$ANNOTATIONPATH/Homo_sapiens/UCSC/hg19/Annotation/Genes/genes.gtf

# Bowtie2 index
INDEX=$ANNOTATIONPATH/Homo_sapiens/UCSC/hg19/Sequence/Bowtie2Index/genome

# directory where downloaded reads should go
DATADIR=/amber2/scratch/jleek/GEUVADIS/data

# directory where BAM files should go when tophat finishes
BDIR=/amber2/scratch/jleek/GEUVADIS/BAM

# number of cores to use for tophat
P=4

while read sampledata
do
    RUNID=`echo $sampledata | cut -d ' ' -f 1`
    SHORTNAME=`echo $RUNID | cut -c1-6`
    SAMPLE=`echo $sampledata | cut -d ' ' -f 2`
    OUTDIR=/amber2/scratch/jleek/GEUVADIS/tophat_${SAMPLE}
    mkdir -p $OUTDIR
    cat > tophat_${SAMPLE}.sh <<EOF
#!/bin/sh

set -e

### download the fastq files:
cd $DATADIR
wget --passive-ftp ftp://ftp.sra.ebi.ac.uk/vol1/fastq/$SHORTNAME/$RUNID/${RUNID}_1.fastq.gz
wget --passive-ftp ftp://ftp.sra.ebi.ac.uk/vol1/fastq/$SHORTNAME/$RUNID/${RUNID}_2.fastq.gz

### run TopHat 
tophat -G $GTF -p $P -o $OUTDIR $INDEX $DATADIR/${RUNID}_1.fastq.gz $DATADIR/${RUNID}_2.fastq.gz

### get alignment file into BAM directory:
mv $OUTDIR/accepted_hits.bam $BDIR/${SAMPLE}_accepted_hits.bam

### delete the rest of the output and the fastq files:
rm -r $OUTDIR
rm $DATADIR/${RUNID}_1.fastq.gz
rm $DATADIR/${RUNID}_2.fastq.gz
EOF
    qsub -cwd -l mf=20G,h_vmem=5G,h_fsize=100G,jabba -M acfrazee+tophat2@gmail.com -pe local $P tophat_${SAMPLE}.sh
done < $PDATA


