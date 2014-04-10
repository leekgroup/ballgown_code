#!/bin/sh
#$ -cwd -l mf=20G,h_vmem=5G,h_fsize=100G -pe local 4

ANNOTATIONPATH=/amber2/scratch/jleek/iGenomes-index

# sequence to use:
SEQU=$ANNOTATIONPATH/Homo_sapiens/UCSC/hg19/Sequence/Bowtie2Index/genome.fa

# make list of assemblies
CDIR=/amber2/scratch/jleek/GEUVADIS/Assembly
ls -1 $CDIR/*.gtf > assemblies.txt

# where should output of cuffmerge go?
OUTDIR=/amber2/scratch/jleek/GEUVADIS/Assembly/merged

# run cuffmerge
cuffmerge -s $SEQU -p 4 -o $OUTDIR assemblies.txt
