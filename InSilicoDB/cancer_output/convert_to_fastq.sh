#!/bin/sh

fastqdump=sratoolkit.2.3.5-ubuntu64/bin/fastq-dump

mkdir tmp

for sample in `ls fastq/*.sra`
do
    cat > ${sample}_tofastq.sh <<EOF
    #!/bin/sh
    $fastqdump --split-3 $sample
    mv $sample tmp
EOF
qsub -l mf=5G,h_vmem=5G -cwd ${sample}_tofastq.sh
done