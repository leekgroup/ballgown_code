#!/usr/bin/python

# script to get SGE emails from account and parse them for job timing information

import contextio as c
import time

### get arguments from command line
from optparse import OptionParser
opts = OptionParser()
opts.add_option("--email", "-e", type="string", help="your email address")
opts.add_option("--alias", "-a", type="string", help="the alias you sent your batch job completion emails to (e.g. myemail+projectname@gmail.com)", default='x')
opts.add_option("--folder", "-d", type="string", help="name of folder or gmail label were the emails of interest live", default='x')
opts.add_option("--limit", "-l", type="int", help="max number of messages to return", default=1000)
opts.add_option("--outfile", "-f", type="string", help="where should I write the output data?")
options, arguments = opts.parse_args()

if options.alias == 'x' and options.folder == 'x':
    raise ValueError('please provide one of alias or folder')

### authentication: get contextio keys
f = open('client_secrets','r')
dat = f.readlines()
CONSUMER_KEY = dat[0].split('\t')[1].strip('\n')
CONSUMER_SECRET = dat[1].split('\t')[1].strip('\n')
f.close()

### create the contextIO object
print 'authenticating...'
context_io_obj = c.ContextIO(
    consumer_key = CONSUMER_KEY,
    consumer_secret = CONSUMER_SECRET
    )

### get info for my email account
accounts = context_io_obj.get_accounts(email = options.email)
if accounts:
    account = accounts[0]
else:
    raise ValueError('failed to access '+options.email)

### grab the emails from the jobs in question
print 'grabbing emails...'
if options.alias != 'x':
    job_reports = account.get_messages(email = options.alias, limit = int(options.limit))
    job_reports = account.get_messages(email = options.alias, limit = int(options.limit))
else:
    job_reports = account.get_messages(folder = options.folder, limit = int(options.limit))
    job_reports = account.get_messages(folder = options.folder, limit = int(options.limit))

if len(job_reports) == 0:
    raise ValueError('no emails for this alias/folder were retrieved')

data = []
print 'parsing statistics from emails [may take several minutes]...'
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

print 'parsing successful!'

### extract wallclock times for each job
def turn_to_hrs(strtime):
    if len(strtime)==3:
        return int(strtime[0]) + float(strtime[1])/60 + float(strtime[2])/3600
    elif len(strtime)==4:
        return int(strtime[0])*24 + int(strtime[1]) + float(strtime[2])/60 + float(strtime[3])/3600
    else:
        raise ValueError('script is not properly handling your wallclock times: please report this as an issue at https://github.com/alyssafrazee/efficiency_analytics')
    
wallclock_times = [d['Wallclock Time'] for d in data]
wallclock_times = map(lambda(x): turn_to_hrs(x.split(':')), wallclock_times)

### extract system times for each job:
def turn_to_minutes(strtime):
    if len(strtime)==3:
        return int(strtime[0])*60+int(strtime[1])+float(strtime[2])/60
    else:
        raise ValueError('script is not properly handling your system times: please report this as an issue at https://github.com/alyssafrazee/efficiency_analytics')

system_times = [d['System Time'] for d in data]
system_times = map(lambda(x): turn_to_minutes(x.split(':')), system_times)

### write out file containing the analytics 
print 'writing out data file...'
with open(options.outfile, 'w') as f:
    f.write('jobid\tnode\twalltime\tsystime\tmemory\tmemunit\tstatus\n')
    i = 0
    for d in data:
        f.write(d['name']+'\t')
        f.write(d['Host']+'\t')
        f.write(str(wallclock_times[i])+'\t')
        f.write(str(system_times[i])+'\t')
        f.write(d['Max vmem'][:-1]+'\t')
        f.write(d['Max vmem'][-1]+'\t')
        f.write(d['Exit Status']+'\n')
        i += 1

### check exit statuses
exit_status = [d['Exit Status'] for d in data]
if not set(exit_status) == set(u'0'):
    print 'warning: some of your jobs exited abnormally (exit status not 0)'

print 'data collection complete!'

