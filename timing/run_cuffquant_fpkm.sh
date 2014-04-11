#!/bin/sh

MAINDIR=/amber2/scratch/jleek/RNASeqSim/original/paper_sim
Q=jabba #queue to run tophat/cufflinks/tablemaker/cuffdiff on
NSAMPLES=20
FOLDERNAME=$MAINDIR/lognormal_directFPKM_geuvadis_FINALPAPER
SLIST=`seq -f %02.0f 1 $NSAMPLES` #list of samples to loop through
CUFFQUANT=/home/bst/student/afrazee/software/cufflinks-2.2.0.Linux_x86_64/cuffquant

for sample in $SLIST
do
    OUTDIR=./sample${sample}_fpkm
    mkdir -p $OUTDIR
    cat > ./cuffquant_fpkm_$sample.sh <<EOF
    #!/bin/sh
    $CUFFQUANT -q -p 4 -o $OUTDIR $FOLDERNAME/assemblies/merged/merged.gtf $FOLDERNAME/alignments/sample${sample}_accepted_hits.bam
EOF
qsub -l mf=10G,h_vmem=3G,$Q -pe local 4 ./cuffquant_fpkm_$sample.sh
done
