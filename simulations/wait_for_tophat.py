#!/usr/bin/python

from optparse import OptionParser
opts = OptionParser()
opts.add_option("--nsamples", "-n", type="int", help="number of samples")
opts.add_option("--dir", "-d", type="string", help="where are the alignments")
options, arguments = opts.parse_args()

import os.path
import time

nsamples = int(options.nsamples)

file_list = [options.dir+'/sample'+str(x).zfill(2)+'_accepted_hits.bam' for x in range(1, nsamples+1)]

while not all(os.path.isfile(x) for x in file_list):
    time.sleep(2)





