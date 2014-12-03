#!/usr/bin/python

import os
import time

sra_files = [x for x in os.listdir('fastq') if x[-3:]=='sra']

while any(os.path.isfile(x) for x in fastq_files):
    time.sleep(2)
