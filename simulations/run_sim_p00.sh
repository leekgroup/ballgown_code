#!/bin/sh
#$ -cwd -l mf=30G,h_vmem=30G,jabba -pe local 4
set -e

# ##########################################################################################
# #### script to run a simulation scenario for negative binomial scenario ##################
# ##########################################################################################

MAINDIR=/amber2/scratch/jleek/RNASeqSim/original/paper_sim
Q=jabba #queue to run tophat/cufflinks/tablemaker/cuffdiff on
ANNOTATIONPATH=/amber2/scratch/jleek/iGenomes-index
SOFTWAREPATH=/home/bst/student/afrazee/software

FASTA=ensembl_chr22.fa
UCSC=0 #1 for TRUE, 0 for FALSE
ANNOTATION=genes-clean.gtf
CHR="22" #must match ANNOTATION. FASTA transcripts should be from this chr.
NSAMPLES=20
FOLDCHANGE=6
FOLDERNAME=$MAINDIR/NBp0_FINALPAPER
PERCENTDE=0.1
RANDOMDE=1 #1 for TRUE, 0 for FALSE
THRESHOLD=0.1
MINLIBSIZE=600000
MAXLIBSIZE=600000
P0=0
MU=300
RATIO=0.005

PYTHON=/home/bst/student/afrazee/software/Python-2.7.2/python
SLIST=`seq -f %02.0f 1 $NSAMPLES` #list of samples to loop through
mkdir -p $FOLDERNAME

#[1] simulate reads
Rscript simReads_NB_p0.R $FASTA $UCSC $NSAMPLES $FOLDCHANGE $FOLDERNAME $PERCENTDE $RANDOMDE $THRESHOLD $MINLIBSIZE $MAXLIBSIZE $P0 $MU $RATIO


#[2] run TopHat
transcriptomeIndex=$ANNOTATIONPATH/Homo_sapiens/Ensembl/GRCh37/Annotation/Transcriptome/known
bowtieIndex=$ANNOTATIONPATH/Homo_sapiens/Ensembl/GRCh37/Sequence/Bowtie2Index/genome
dataDir=$FOLDERNAME/data

for sample in $SLIST
do
    outdir=$FOLDERNAME/alignments/sample${sample}
    cat > $FOLDERNAME/tophat_${sample}.sh <<EOF
    #!/bin/sh
    set -e
    mkdir -p $outdir
    tophat -o $outdir -p 1 --transcriptome-index $transcriptomeIndex $bowtieIndex $dataDir/sample_${sample}_1.fasta $dataDir/sample_${sample}_2.fasta
    mv $outdir/accepted_hits.bam $FOLDERNAME/alignments/sample${sample}_accepted_hits.bam 
EOF
    qsub -cwd -l mf=20G,h_vmem=5G,$Q -m n $FOLDERNAME/tophat_${sample}.sh
done

### wait until all TopHat runs are done (check for all completed files every 2 seconds)
$PYTHON wait_for_tophat.py -n $NSAMPLES -d $FOLDERNAME/alignments
mkdir -p $FOLDERNAME/tophat_scripts
mv $FOLDERNAME/tophat_??.sh* $FOLDERNAME/tophat_scripts/




#[3] run Cufflinks
CUFFLINKS=$SOFTWAREPATH/cufflinks-2.1.1.Linux_x86_64/cufflinks

for sample in $SLIST
do
    OUTDIR=$FOLDERNAME/assemblies/sample${sample}
    mkdir -p $OUTDIR
    cat > $FOLDERNAME/cufflinks_$sample.sh <<EOF
    #!/bin/sh
    $CUFFLINKS -q -p 4 -o $OUTDIR $FOLDERNAME/alignments/sample${sample}_accepted_hits.bam
    mv $OUTDIR/transcripts.gtf $FOLDERNAME/assemblies/sample_${sample}_transcripts.gtf
EOF
qsub -l mf=10G,h_vmem=3G,$Q -pe local 4 -m n $FOLDERNAME/cufflinks_$sample.sh
done

### wait until all Cufflinks runs are done (check for all completed files every 2 seconds) and write out assemblies.txt for use in merge step
$PYTHON wait_for_cufflinks.py -n $NSAMPLES -d $FOLDERNAME/assemblies
mkdir -p $FOLDERNAME/cufflinks_scripts
mv $FOLDERNAME/cufflinks_??.sh* $FOLDERNAME/cufflinks_scripts



#[4] run Cuffmerge
CUFFMERGE=$SOFTWAREPATH/cufflinks-2.1.1.Linux_x86_64/cuffmerge
ASSEMBLYFILE=$FOLDERNAME/assemblies/assemblies.txt
OUTDIR=$FOLDERNAME/assemblies/merged
REFSEQ=$ANNOTATIONPATH/Homo_sapiens/Ensembl/GRCh37/Sequence/Bowtie2Index/genome.fa

$CUFFMERGE -s $REFSEQ -o $OUTDIR $ASSEMBLYFILE





#[5] run Tablemaker
MERGEDASSEMBLY=$OUTDIR/merged.gtf
OUTDIR=$FOLDERNAME/ballgown
TABLEMAKER=$SOFTWAREPATH/tablemaker
ALIGNMENTDIR=$FOLDERNAME/alignments

for sample in $SLIST
do
  cat > $FOLDERNAME/ballgown_$sample.sh <<EOF
  #!/bin/sh
  $TABLEMAKER -q -W -G $MERGEDASSEMBLY -o $OUTDIR/sample${sample} $ALIGNMENTDIR/sample${sample}_accepted_hits.bam
  echo 'done' > $OUTDIR/sample${sample}_done
EOF
qsub -l mf=10G,h_vmem=3G,$Q -pe local 4 -M acfrazee+ballgownsimNB@gmail.com $FOLDERNAME/ballgown_$sample.sh 
done




#[6] run Cuffdiff
CUFFDIFF=$SOFTWAREPATH/cufflinks-2.1.1.Linux_x86_64/cuffdiff

# create comma-separate lists of samples!
N1=$(( $NSAMPLES / 2 ))
S2=$(( $N1 + 1 ))

######### group1:
group1=""
for ((n=1; n<=N1; n++)); do
    [[ -n "$group1" ]] && group1="$group1,"
    printf -v group1 "%s$ALIGNMENTDIR/sample%02d_accepted_hits.bam" "$group1" "$n"
done
######## group 2:
group2=""
for ((n=S2; n<=NSAMPLES; n++)); do
    [[ -n "$group2" ]] && group2="$group2,"
    printf -v group2 "%s$ALIGNMENTDIR/sample%02d_accepted_hits.bam" "$group2" "$n"
done

######### run:
echo 'CUFFDIFF START'
echo `date`
$CUFFDIFF -p 4 -L group1,group2 -o $FOLDERNAME/cuffdiff $MERGEDASSEMBLY $group1 $group2
echo 'CUFFDIFF END'
echo `date`


#[7] make sure tablemaker jobs have finished
$PYTHON wait_for_tablemaker.py -n $NSAMPLES -d $FOLDERNAME/ballgown
mkdir -p $FOLDERNAME/ballgown_scripts
mv $FOLDERNAME/ballgown_??.sh* $FOLDERNAME/ballgown_scripts
rm $FOLDERNAME/ballgown/*_done


