#!/bin/sh

## run Cufflinks on the GEUVADIS data 
## TopHat has already been run

# where are the alignments?
BDIR=/amber2/scratch/jleek/GEUVADIS/BAM

# where should cufflinks output go?
CDIR=/amber2/scratch/jleek/GEUVADIS/Assembly

# number of cores to use
P=4

# make/submit scripts
for sample in `ls -1 $BDIR`
do
    NAME=`echo $sample | awk '{ print substr( $0, 1, length($0)-18 ) }'`
    cat > ${sample}_cufflinks.sh <<EOF 
#!/bin/bash

set -e

### run cufflinks
mkdir -p $CDIR/$NAME
cufflinks -q -p $P -o $CDIR/$NAME $BDIR/$sample

### move gtf file out of sample folder and into main Assembly folder:
mv $CDIR/$NAME/transcripts.gtf $CDIR/${NAME}-transcripts.gtf

### delete other cufflinks output and bam file:
rm -r $CDIR/$NAME
rm $BDIR/$sample

EOF
  qsub -cwd -l jabba,mem_free=30G,h_vmem=7G,h_fsize=256G -pe local $P ${sample}_cufflinks.sh
done


