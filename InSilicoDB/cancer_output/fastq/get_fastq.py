#!/usr/bin/python

# get only the samples we want to analyze, cancer dataset
# # A high dimensional deep sequencing study of non-small cell lung adenocarcinoma in never-smoker Korean females
# http://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE37764

# url: http://www.ncbi.nlm.nih.gov/sra?term=SRP012656
# then click "send to" in upper right, and choose "file"; check the run info option,
# the file will be SraRunInfo.csv

import csv

# read info from SRA:
with open('../SraRunInfo.csv', 'r') as f:
    lines = csv.reader(f)
    linelist = [row for row in lines]

colnames = linelist.pop(0)
url_ind = colnames.index('download_path')
description_ind = colnames.index('LibraryName')
ids = [x[description_ind].split(':')[0] for x in linelist]

# the "clinical annotation" button in insilico db:
with open('../metadata.txt', 'r') as f:
    mlines = f.readlines()
    colnames = mlines.pop(0).split('\t')
    haveids = [x.split('\t')[0] for x in mlines]

# check to make sure we have information from all the samples:
assert len(set(haveids) - set(ids)) == 0

# download the appropriate sra files:
from subprocess import call
from re import search
RNAseq = [x for x in linelist if search('(?<!sm)RNA-seq', x[description_ind])]
RNAseqIDs = [x[description_ind].split(':')[0] for x in RNAseq]
assert len(set(RNAseqIDs)) == 12 #make sure we have the right number of samples

for sample in RNAseq:
    call(['wget', sample[url_ind]])


