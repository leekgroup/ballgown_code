#!/bin/sh
#$ -cwd -l mf=200G,h_vmem=50G -pe local 4
## run analysis pipeline for insilicodb dataset #2
set -e
set -u

# move to fastq folder
mkdir -p fastq
cd fastq  

# download the .sra files (done)
python get_fastq.py 

# convert .sra file to .fastq file with sratoolkit (done)
sh ../convert_to_fastq.sh 

# wait until all .sra files are converted:
# (takes 30-40 minutes apiece)
cd ..
python wait_for_fastq.py

# run TopHat: (remember, we are still located in the fastq folder)
transcriptomeIndex=Homo_sapiens/UCSC/hg19/Annotation/Transcriptome/known
bowtieIndex=Homo_sapiens/UCSC/hg19/Sequence/Bowtie2Index/genome
alignmentdir=alignments
mkdir -p ${alignmentdir}/scripts
SLIST=`ls fastq/*.fastq`

for sample in $SLIST
do
   NAME=`echo $sample | cut -c1-9`
   outdir=${alignmentdir}/${NAME}
   cat > ${alignmentdir}/scripts/tophat_${NAME}.sh <<EOF
   #!/bin/sh
   set -e
   mkdir -p $outdir
   module load tophat #put tophat in path
   tophat -o $outdir -p 4 --transcriptome-index $transcriptomeIndex $bowtieIndex fastq/${NAME}.fastq
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

######### embryonic group:
embryonic=""
for esamp in `cat fastq/match_ids.txt | cut -c11-19 | tail -n +2 | head -34`; do
    [[ -n "$embryonic" ]] && embryonic="$embryonic,"
    printf -v embryonic "%s$alignmentdir/${esamp}_accepted_hits.bam" "$embryonic"
done
######## group 2:
blast=""
for bsamp in `cat fastq/match_ids.txt | cut -c11-19 | tail -n +2 | tail -78`; do
    [[ -n "$blast" ]] && blast="$blast,"
    printf -v blast "%s$alignmentdir/${bsamp}_accepted_hits.bam" "$blast" 
done

module load cufflinks
cuffdiff -p 4 -L embryonic,blast -o $OUTDIR $MERGEDASSEMBLY $embryonic $blast

