#!/usr/bin/python

# get only the samples we want to analyze, cell type dataset
# Tracing pluripotency of human early embryos and embryonic stem cells by single cell RNA-seq
# http://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE36552

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
    colnamesm = mlines.pop(0).split('\t')
    haveids = [x.split('\t')[0] for x in mlines]

# check to make sure we have information from all the samples:
assert len(set(haveids) - set(ids)) == 0

# download the appropriate sra files:
#### there are 2 lists that aren't in the same order:
#### the runInfo list (including ids, linelist)
#### and the metadata list (including haveids, mlines, and group)
to_download = []
num_stem = 0
num_blast = 0
group = [x.split('\t')[1] for x in mlines]
# get URLs to download and write out file matching GSM ids to SRA read accession IDs
with open('../match_ids.txt', 'w') as f:
    f.write('GSMid\tSRAid\tgroup\n')
    for i in range(len(ids)):
        if group[i] == 'human embryonic stem cell':
            num_stem += 1
            datindex = ids.index(haveids[i])
            to_download.append(linelist[datindex][url_ind])
            f.write(haveids[i]+'\t'+linelist[datindex][0]+'\t'+'embryonic'+'\n')
        elif group[i] == 'human preimplantation blastomere':
            num_blast += 1
            datindex = ids.index(haveids[i])
            to_download.append(linelist[datindex][url_ind])
            f.write(haveids[i]+'\t'+linelist[datindex][0]+'\t'+'blastomere'+'\n')

# make sure we got the right number in each group:
assert num_stem==34 and num_blast==78

# download data
from subprocess import call
for sample in to_download:
    call(['wget', sample])


