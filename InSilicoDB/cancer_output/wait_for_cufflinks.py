#!/usr/bin/python

from optparse import OptionParser
opts = OptionParser()
opts.add_option("--maindir", "-m", type="string", help="base directory for the project, no slash at end")
options, arguments = opts.parse_args()

import os
import time

sample_ids = [x[:-6] for x in os.listdir('./fastq') if x[-5:]=='fastq']
gtf_files = [options.maindir+'/assemblies/'+x+'_transcripts.gtf' for x in sample_ids]

while not all(os.path.isfile(x) for x in gtf_files):
    time.sleep(2)

with open(options.maindir+'/assemblies/assemblies.txt', 'w') as f:
    for fl in gtf_files:
        f.write(fl+'\n')


