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

### access your email account
accounts = context_io_obj.get_accounts(email='me@email.com') 
if accounts:
    account = accounts[0]
else:
    raise ValueError('failed to access '+options.email)

### grab the emails from the jobs in question
tophat_reports = account.get_messages(email="me+tophatNB@email.com", limit=200)
cufflinks_reports = account.get_messages(email="me+cufflinksNB@email.com", limit=200)
tablemaker_reports = account.get_messages(email="me+tablemakerNB@email.com", limit=200)
cuffquant_reports = account.get_messages(email="me+cuffquantNB@email.com", limit=200)
data = []
for job in tophat_reports+cufflinks_reports+tablemaker_reports+cuffquant_reports:
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

### functions to grab average time for specific jobs:
def turn_to_hrs(strtime):
    return int(strtime[0])+float(strtime[1])/60+float(strtime[2])/3600

def get_time(jobtype, dataset):
    times = [d['Wallclock Time'] for d in dataset if jobtype in d['name']]
    times = map(lambda(x): x.split(':'), times)
    times = map(turn_to_hrs, times)
    return float(sum(times))/len(times) 

get_time('tophat', data) #0.94 hours = 56.4 minutes
get_time('cufflinks', data)*60 #1.97 minutes
get_time('ballgown', data)*60 #5.38 minutes
get_time('cuffquant', data)*60 #3.09 minutes

with open('simtimes.txt','w') as f:
    f.write('sample\ttophat\tcufflinks\tballgown\tcuffquant\n')
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
        cqtimest = [d['Wallclock Time'] for d in data if 'cuffquant_NB_'+samp in d['name']]
        if cqtimest:
            cqtimest = cqtimest[0]
            cqtimesp = cqtimest.split(':')
            cqtime = turn_to_hrs(cqtimesp)
        else:
            cqtime = 'NA' ## sge failed to send emails for 4 jobs, but still a decent estimate of times.
        f.write(samp+'\t'+str(ttime)+'\t'+str(ctime)+'\t'+str(btime)+'\t'+str(cqtime)+'\n')


