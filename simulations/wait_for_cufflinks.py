#!/usr/bin/python

from optparse import OptionParser
opts = OptionParser()
opts.add_option("--nsamples", "-n", type="int", help="number of samples")
opts.add_option("--dir", "-d", type="string", help="where are the assemblies")
options, arguments = opts.parse_args()

import os.path
import time

nsamples = int(options.nsamples)

file_list = [options.dir+'/sample_'+str(x).zfill(2)+'_transcripts.gtf' for x in range(1, nsamples+1)]

while not all(os.path.isfile(x) for x in file_list):
    time.sleep(2)

# then write out assemblies.txt
with open(options.dir+'/assemblies.txt', 'w') as f:
    for fl in file_list:
        f.write(fl+'\n')






