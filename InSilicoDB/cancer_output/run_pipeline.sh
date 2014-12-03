#!/bin/sh
#$ -cwd -l mf=20G,h_vmem=5G -pe local 4
## run analysis pipeline for insilicodb dataset #1
set -e
set -u

# make folder for fastq files
mkdir -p fastq

# download the .sra files into the fastq folder
cd fastq
python get_fastq.py 

# convert .sra file to .fastq file with sratoolkit
sh ../convert_to_fastq.sh 

# wait until all .sra files are converted:
# (takes 30-40 minutes apiece)
cd ..
python wait_for_fastq.py


# run TopHat: 
transcriptomeIndex=Homo_sapiens/UCSC/hg19/Annotation/Transcriptome/known
bowtieIndex=Homo_sapiens/UCSC/hg19/Sequence/Bowtie2Index/genome
alignmentdir=alignments
mkdir -p alignments/scripts
SLIST=`ls fastq/*_1.fastq.gz`

for sample in $SLIST
do
     NAME=`echo $sample | cut -c1-9`
     outdir=${alignmentdir}/${NAME}
     cat > ${alignmentdir}/scripts/tophat_${NAME}.sh <<EOF
     #!/bin/sh
     set -e
     mkdir -p $outdir
     module load tophat #put tophat in path
     tophat -o $outdir -p 4 --transcriptome-index $transcriptomeIndex $bowtieIndex fastq/${NAME}_1.fastq.gz fastq/${NAME}_2.fastq.gz
     mv $outdir/accepted_hits.bam ${alignmentdir}/${NAME}_accepted_hits.bam 
EOF
     qsub -l mf=20G,h_vmem=5G -pe local 4 $alignmentdir/scripts/tophat_${NAME}.sh
done

# wait for tophat jobs to be done:
python wait_for_tophat.py

# run Cufflinks (do the counting for the annotated transcripts, since that's what it appears they did in inSilicoDb)
assemblydir=assemblies
GTF=Homo_sapiens/UCSC/hg19/Annotation/Genes/genes.gtf
mkdir -p $assemblydir/scripts
for sample in $SLIST
do  
    NAME=`echo $sample | cut -c1-9`
    outdir=${assemblydir}/$NAME
    cat > ${assemblydir}/scripts/cufflinks_${NAME}.sh <<EOF
    #!/bin/sh
    set -e 
    mkdir -p $outdir
    module load cufflinks #put cufflinks in path
    cufflinks -o $outdir -p 4 -q -G $GTF ${alignmentdir}/${NAME}_accepted_hits.bam
    mv $outdir/transcripts.gtf $assemblydir/${NAME}_transcripts.gtf
EOF
    qsub -l mf=20G,h_vmem=5G -pe local 4 ${assemblydir}/scripts/cufflinks_${NAME}.sh
done

# wait for Cufflinks to finish; write out assembly file
python wait_for_cufflinks.py --maindir .

# run Cuffmerge
module load cufflinks
ASSEMBLYFILE=assemblies/assemblies.txt
OUTDIR=assemblies/merged
REFSEQ=Homo_sapiens/UCSC/hg19/Sequence/Bowtie2Index/genome.fa
cuffmerge -s $REFSEQ -o $OUTDIR $ASSEMBLYFILE

# run Cuffdiff
OUTDIR=cuffdiff
MERGEDASSEMBLY=assemblies/merged/merged.gtf

cuffdiff -p 4 -L normal,tumor -o $OUTDIR $MERGEDASSEMBLY alignments/SRR493937_accepted_hits.bam,alignments/SRR493938_accepted_hits.bam,alignments/SRR493941_accepted_hits.bam,alignments/SRR493942_accepted_hits.bam,alignments/SRR493945_accepted_hits.bam,alignments/SRR493946_accepted_hits.bam,alignments/SRR493949_accepted_hits.bam,alignments/SRR493950_accepted_hits.bam,alignments/SRR493953_accepted_hits.bam,alignments/SRR493954_accepted_hits.bam,alignments/SRR493957_accepted_hits.bam,alignments/SRR493958_accepted_hits.bam alignments/SRR493939_accepted_hits.bam,alignments/SRR493940_accepted_hits.bam,alignments/SRR493943_accepted_hits.bam,alignments/SRR493944_accepted_hits.bam,alignments/SRR493947_accepted_hits.bam,alignments/SRR493948_accepted_hits.bam,alignments/SRR493951_accepted_hits.bam,alignments/SRR493952_accepted_hits.bam,alignments/SRR493955_accepted_hits.bam,alignments/SRR493956_accepted_hits.bam,alignments/SRR493959_accepted_hits.bam,alignments/SRR493960_accepted_hits.bam
