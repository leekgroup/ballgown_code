#!/bin/sh
#$ -cwd -l mf=300G,h_vmem=75G -pe local 4
set -e

MERGED=merged.gtf
ALIGNMENTDIR=BAM
GROUPFILE=sex_info.txt

## R script (positive_control.Rmd) wrote out the sex_info file
male=""
female=""
while read groupdat
do
    DIRNAME=`echo $groupdat | cut -d ' ' -f 1`
    SEX=`echo $groupdat | cut -d ' ' -f 2`
    if [ $SEX = 'male' ]
    then 
        [[ -n "$male" ]] && male="$male,"
        printf -v male "%s$ALIGNMENTDIR/${DIRNAME}_accepted_hits.bam" "$male"
    else
        [[ -n "$female" ]] && female="$female,"
        printf -v female "%s$ALIGNMENTDIR/${DIRNAME}_accepted_hits.bam" "$female"
    fi

    # don't need to download alignment files for this one
    # (downloaded them for negative control)

done < $GROUPFILE 

echo $male
echo $female

echo 'CUFFDIFF START'
echo `date`
cuffdiff -p 4 -L male,female -o ./cuffdiff $MERGED $male $female
echo 'CUFFDIFF END'
echo `date`




