#!/bin/sh
#$ -cwd -l mf=20G,h_vmem=5G,jabba -pe local 4

MAINDIR=/amber2/scratch/jleek/RNASeqSim/original/paper_sim
FOLDERNAME=$MAINDIR/lognormal_directFPKM_geuvadis_FINALPAPER
CUFFDIFF=/home/bst/student/afrazee/software/cufflinks-2.2.0.Linux_x86_64/cuffdiff
MERGEDASSEMBLY=$FOLDERNAME/assemblies/merged/merged.gtf
group1=sample01_fpkm/abundances.cxb,sample02_fpkm/abundances.cxb,sample03_fpkm/abundances.cxb,sample04_fpkm/abundances.cxb,sample05_fpkm/abundances.cxb,sample06_fpkm/abundances.cxb,sample07_fpkm/abundances.cxb,sample08_fpkm/abundances.cxb,sample09_fpkm/abundances.cxb,sample10_fpkm/abundances.cxb
group2=sample11_fpkm/abundances.cxb,sample12_fpkm/abundances.cxb,sample13_fpkm/abundances.cxb,sample14_fpkm/abundances.cxb,sample15_fpkm/abundances.cxb,sample16_fpkm/abundances.cxb,sample17_fpkm/abundances.cxb,sample18_fpkm/abundances.cxb,sample19_fpkm/abundances.cxb,sample20_fpkm/abundances.cxb

$CUFFDIFF -p 4 -L group1,group2 -o ./cuffdiff_fpkm $MERGEDASSEMBLY $group1 $group2