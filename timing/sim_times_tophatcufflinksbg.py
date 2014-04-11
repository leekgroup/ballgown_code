#!/usr/bin/python

## script to get SGE emails from account and parse them for job timing information

import contextio as c
import time

### authentication: get contextio keys
f = open('client_secrets','r')
dat = f.readlines()
CONSUMER_KEY = dat[0].split('\t')[1].strip('\n')
CONSUMER_SECRET = dat[1].split('\t')[1].strip('\n')
f.close()

### create the contextIO object
context_io_obj = c.ContextIO(
    consumer_key = CONSUMER_KEY,
    consumer_secret = CONSUMER_SECRET
    )

### grab the emails from the jobs in question
job_reports = account.get_messages(email="myemail+stiming@gmail.com", limit=200)
data = []
for job in job_reports:
    ## avoid the API limit (120 requests max in 30 seconds)
    ## solution: make each request take at least 0.25 seconds
    time.sleep(0.25)
    message = job.get_body()[0]['content']
    stats = [elem.strip().split('=') for elem in message.split('\r\n')]
    stats = [map(lambda(x): x.strip(), elem) for elem in stats]
    jobinfo = dict()
    jobinfo['name'] = stats.pop(0)[0].replace('(',')').split(')')[1]
    for elem in stats:
        if elem[0]:
            jobinfo[elem[0]] = elem[1]
    jobinfo['Queue'] = jobinfo['Queue'].split('@')[0]
    data.append(jobinfo)

### tophat times:
tophat_times = [d['Wallclock Time'] for d in data if 'tophat' in d['name']]
tophat_times = map(lambda(x): x.split(':'), tophat_times)
def turn_to_hrs(strtime):
    return int(strtime[0])+float(strtime[1])/60+float(strtime[2])/3600
tophat_times = map(turn_to_hrs, tophat_times)
sum(tophat_times)/len(tophat_times) ## 2.04 hours

### cufflinks times
cufflinks_times = [d['Wallclock Time'] for d in data if 'cufflinks' in d['name']]
cufflinks_times = map(lambda(x): x.split(':'), cufflinks_times)
cufflinks_times = map(turn_to_hrs, cufflinks_times)
sum(cufflinks_times)/len(cufflinks_times)*60 ## 4.85 minutes

### tablemaker times
tablemaker_times = [d['Wallclock Time'] for d in data if 'ballgown' in d['name']]
tablemaker_times = map(lambda(x): x.split(':'), tablemaker_times)
tablemaker_times = map(turn_to_hrs, tablemaker_times)
sum(tablemaker_times)/len(tablemaker_times)*60 ## 3.21 minutes

with open('simtimes.txt','w') as f:
    f.write('sample\ttophat\tcufflinks\tballgown\n')
    for samp in [str(x).zfill(2) for x in range(1,21)]:
        ttimest = [d['Wallclock Time'] for d in data if 'tophat_'+samp in d['name']][0]
        ttimesp = ttimest.split(':')
        ttime = turn_to_hrs(ttimesp)
        ctimest = [d['Wallclock Time'] for d in data if 'cufflinks_'+samp in d['name']][0]
        ctimesp = ctimest.split(':')
        ctime = turn_to_hrs(ctimesp)
        btimest = [d['Wallclock Time'] for d in data if 'ballgown_'+samp in d['name']][0]
        btimesp = btimest.split(':')
        btime = turn_to_hrs(btimesp)
        f.write(samp+'\t'+str(ttime)+'\t'+str(ctime)+'\t'+str(btime)+'\n')


