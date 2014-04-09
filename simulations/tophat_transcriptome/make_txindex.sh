#!/bin/sh
#$ -cwd -l mf=20G,h_vmem=20G,h_fsize=100G,jabba

## this script makes a transcriptome index for TopHat 
## so that you don't have to wait for it to be built every time you use -G with this annotation

KNOWNGENES=$ANNOTATIONPATH/Homo_sapiens/Ensembl/GRCh37/Annotation/Genes/genes.gtf
TINDEX=$ANNOTATIONPATH/Homo_sapiens/Ensembl/GRCh37/Annotation/Transcriptome/known
BOWTIEINDEX=$ANNOTATIONPATH/Homo_sapiens/Ensembl/GRCh37/Sequence/Bowtie2Index/genome

tophat -G $KNOWNGENES --transcriptome-index=$TINDEX $BOWTIEINDEX tiny1.fasta tiny2.fasta