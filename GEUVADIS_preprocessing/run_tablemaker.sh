#!/bin/sh

### run tablemaker on GEUVADIS data

# directory with bam files
BDIR=/amber2/scratch/jleek/GEUVADIS/BAM

# merged assembly:
MASM=/amber2/scratch/jleek/GEUVADIS/Assembly/merged/merged.gtf

# number of cores:
P=4

# file with sample, readID, and phenotype data (same as used in tophat)
SDAT=pop_data_annot_whole.txt

# make a script for each sample and qsub it:
while read sampledata
do
    SAMPLE=`echo $sampledata | cut -d ' ' -f 2`
    BGOUTDIR=/amber2/scratch/jleek/GEUVADIS/Ballgown/$SAMPLE
    mkdir -p $BGOUTDIR
    cat > ${SAMPLE}_ballgown.sh <<EOF
#!/bin/bash
set -e 

# run tablemaker
tablemaker -p $P -q -W -G $MASM -o $BGOUTDIR $BDIR/${SAMPLE}_accepted_hits.bam
EOF
    qsub -cwd -l jabba,mem_free=30G,h_vmem=7G,h_fsize=256G -pe local $P ${SAMPLE}_ballgown.sh
done < $SDAT 
