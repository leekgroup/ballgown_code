#!/usr/bin/python
# get tophat times for GEUVADIS

import os

def turn_to_hrs(strtime):
    strtime = strtime.split(":")
    if len(strtime)==3:
        return int(strtime[0]) + float(strtime[1])/60 + float(strtime[2])/3600
    elif len(strtime)==4:
        return int(strtime[0])*24 + int(strtime[1]) + float(strtime[2])/60 + float(strtime[3])/3600
    else:
        raise ValueError('weird time, yo')

logfiles = os.listdir('/amber2/scratch/jleek/GEUVADIS/BAM/tophat_logs')
with open('tophat_times.txt','w') as f:
    f.write('sample\ttime\n')
    for l in logfiles:
        with open(l, 'r') as lf:
            for line in lf:
                pass
            elapsedtime = turn_to_hrs(line[-17:-8])
        f.write(l[7:-4]+'\t'+str(elapsedtime)+'\n')


