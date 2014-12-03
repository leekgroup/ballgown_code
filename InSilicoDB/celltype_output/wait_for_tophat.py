#/usr/bin/python

import os
import time

sample_ids = [x[:-6] for x in os.listdir('./fastq') if x[-5:]=='fastq']
bam_files = ['./alignments/'+x+'_accepted_hits.bam' for x in sample_ids]

while not all(os.path.isfile(x) for x in bam_files):
    time.sleep(2)
