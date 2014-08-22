#!/bin/sh
#$ -cwd -l mf=30G,h_vmem=8G -pe local 4
set -e

# ##########################################################################################
# #### script to run a simulation scenario using whatever's in simReads_customreadmat.R ####
# ##########################################################################################

MAINDIR=/amber2/scratch/jleek/RNASeqSim/original/paper_sim
ANNOTATIONPATH=/amber2/scratch/jleek/iGenomes-index
SOFTWAREPATH=/home/bst/student/afrazee/software

FASTA=/amber2/scratch/jleek/RNASeqSim/original/paper_sim/ensembl_chr22.fa
UCSC=0 #1 for TRUE, 0 for FALSE
ANNOTATION=$ANNOTATIONPATH/Homo_sapiens/Ensembl/GRCh37/Annotation/Genes/genes-clean.gtf
CHR="22" #must match ANNOTATION. FASTA transcripts should be from this chr.
NSAMPLES=20
FOLDCHANGE=6
FOLDERNAME=$MAINDIR/FINAL_fpkm
PERCENTDE=0.1
MINLIBSIZE=150000
MAXLIBSIZE=150000
GEUVADISBG=/amber2/scratch/jleek/GEUVADIS/Ballgown/small_objects/fpkm.rda 

PYTHON=/home/bst/student/afrazee/software/Python-2.7.2/python
SLIST=`seq -f %02.0f 1 $NSAMPLES` #list of samples to loop through
mkdir -p $FOLDERNAME

# #[1] simulate reads
Rscript simReads_FPKM_direct_geuvadis.R $FASTA $UCSC $NSAMPLES $FOLDCHANGE $FOLDERNAME $PERCENTDE $MINLIBSIZE $MAXLIBSIZE $GEUVADISBG



# #[2] run TopHat
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
    module load tophat
    tophat -o $outdir -p 1 --transcriptome-index $transcriptomeIndex $bowtieIndex $dataDir/sample_${sample}_1.fasta $dataDir/sample_${sample}_2.fasta
    mv $outdir/accepted_hits.bam $FOLDERNAME/alignments/sample${sample}_accepted_hits.bam 
EOF
    qsub -cwd -l mf=20G,h_vmem=5G -m e -M acfrazee+tophatFPKM@gmail.com -pe local 4 $FOLDERNAME/tophat_${sample}.sh
done

### wait until all TopHat runs are done (check for all completed files every 2 seconds)
$PYTHON ../wait_for_tophat.py -n $NSAMPLES -d $FOLDERNAME/alignments
mkdir -p $FOLDERNAME/tophat_scripts
mv $FOLDERNAME/tophat_??.sh* $FOLDERNAME/tophat_scripts/





#[3] run Cufflinks
CUFFLINKS=$SOFTWAREPATH/cufflinks-2.2.1.Linux_x86_64/cufflinks

for sample in $SLIST
do
    OUTDIR=$FOLDERNAME/assemblies/sample${sample}
    mkdir -p $OUTDIR
    cat > $FOLDERNAME/cufflinks_$sample.sh <<EOF
    #!/bin/sh
    $CUFFLINKS -q -p 4 -o $OUTDIR $FOLDERNAME/alignments/sample${sample}_accepted_hits.bam
    mv $OUTDIR/transcripts.gtf $FOLDERNAME/assemblies/sample_${sample}_transcripts.gtf
EOF
qsub -l mf=10G,h_vmem=3G -pe local 4 -m e -M acfrazee+cufflinksFPKM@gmail.com $FOLDERNAME/cufflinks_$sample.sh
done

### wait until all Cufflinks runs are done (check for all completed files every 2 seconds) and write out assemblies.txt for use in merge step
$PYTHON ../wait_for_cufflinks.py -n $NSAMPLES -d $FOLDERNAME/assemblies
mkdir -p $FOLDERNAME/cufflinks_scripts
mv $FOLDERNAME/cufflinks_??.sh* $FOLDERNAME/cufflinks_scripts



# #[4] run Cuffmerge
CUFFMERGE=$SOFTWAREPATH/cufflinks-2.2.1.Linux_x86_64/cuffmerge
ASSEMBLYFILE=$FOLDERNAME/assemblies/assemblies.txt
OUTDIR=$FOLDERNAME/assemblies/merged
REFSEQ=$ANNOTATIONPATH/Homo_sapiens/Ensembl/GRCh37/Sequence/Bowtie2Index/genome.fa

$CUFFMERGE -s $REFSEQ -o $OUTDIR $ASSEMBLYFILE






#[5] run Tablemaker
MERGEDASSEMBLY=$OUTDIR/merged.gtf
OUTDIR=$FOLDERNAME/ballgown
TABLEMAKER=$SOFTWAREPATH/tablemaker-2.1.1.Linux_x86_64/tablemaker
ALIGNMENTDIR=$FOLDERNAME/alignments

for sample in $SLIST
do
  cat > $FOLDERNAME/ballgown_$sample.sh <<EOF
  #!/bin/sh
  $TABLEMAKER -q -W -G $MERGEDASSEMBLY -o $OUTDIR/sample${sample} $ALIGNMENTDIR/sample${sample}_accepted_hits.bam
  echo 'done' > $OUTDIR/sample${sample}_done
EOF
qsub -l mf=10G,h_vmem=3G,$Q -pe local 4 $FOLDERNAME/ballgown_$sample.sh 
done




#[6] run Cuffdiff
CUFFDIFF=$SOFTWAREPATH/cufflinks-2.2.1.Linux_x86_64/cuffdiff

# create comma-separate lists of samples!
N1=$(( $NSAMPLES / 2 ))
S2=$(( $N1 + 1 ))

######### group1:
group1=""
for ((n=1; n<=N1; n++)); do
    [[ -n "$group1" ]] && group1="$group1,"
    printf -v group1 "%s$ALIGNMENTDIR/sample%02d_accepted_hits.bam" "$group1" "$n"
done
######### group 2:
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
$PYTHON ../wait_for_tablemaker.py -n $NSAMPLES -d $FOLDERNAME/ballgown
mkdir -p $FOLDERNAME/ballgown_scripts
mv $FOLDERNAME/ballgown_??.sh* $FOLDERNAME/ballgown_scripts
rm $FOLDERNAME/ballgown/*_done