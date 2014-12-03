#!/bin/sh
#$ -cwd -l mf=300G,h_vmem=75G -pe local 4
set -e

MERGED=Assembly/merged/merged.gtf
ALIGNMENTDIR=BAM
GROUPFILE=random_groups.txt

## R script (negative_control.Rmd) randomly assigned samples to groups
## wrote out group assignments in $GROUPFILE
group0=""
group1=""
while read groupdat
do
    DIRNAME=`echo $groupdat | cut -d ' ' -f 1`
    GROUP=`echo $groupdat | cut -d ' ' -f 2`
    if [ $GROUP -eq 0 ]
    then 
        [[ -n "$group0" ]] && group0="$group0,"
        printf -v group0 "%s$ALIGNMENTDIR/${DIRNAME}_accepted_hits.bam" "$group0"
    else
        [[ -n "$group1" ]] && group1="$group1,"
        printf -v group1 "%s$ALIGNMENTDIR/${DIRNAME}_accepted_hits.bam" "$group1"
    fi

    # download alignment file from ArrayExpress if we don't already have it.
    if [ ! -e $ALIGNMENTDIR/${DIRNAME}_accepted_hits.bam ]
    then
        wget -nv -P $ALIGNMENTDIR http://www.ebi.ac.uk/arrayexpress/files/E-GEUV-6/${DIRNAME}_accepted_hits.bam
    fi
    echo $DIRNAME downloaded

done < $GROUPFILE 

echo 'CUFFDIFF START'
echo `date`
cuffdiff -p 4 -L group0,group1 -o ./cuffdiff $MERGED $group0 $group1
echo 'CUFFDIFF END'
echo `date`
