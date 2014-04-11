## timing results

Timing results are presented in the manuscript for each preprocessing step in the analysis of the GEUVADIS dataset. Specifically we provide per-sample timing summaries for TopHat, Cufflinks, and Tablemaker. Code for these preprocessing steps is available in the [GEUVADIS_preprocessing subfolder] of this repo. The code here produces Figure 5 (all panels).

The manuscript also gives timing results for a small simulated dataset, scenario #1 as described in the [simulations subfolder](https://github.com/alyssafrazee/ballgown_code/tree/master/simulations) of this repo (the subfolder also contains code for the simulations).

### obtaining runtimes
I obtained exact runtimes by relying on Sun Grid Engine's batch job completion emails. 

To do this, you will need to modify some of the preprocessing scripts to send you an email when the job finishes. I used Gmail's [+ operator](https://support.google.com/mail/answer/12096?hl=en) (a make-your-own-alias trick) to send emails from each processing step to a different alias. To replicate this process, the `qsub` calls for the jobs in question need a `-M` argument. Here's an outline of what needs to be edited. 
* GEUVADIS: 
    - `run_cufflinks.sh`: line 36, add `-m e -M youremail+gcufflinks@gmail.com` to the `qsub` call
    - `run_tablemaker.sh`: line 30, add `-m e -M youremail+gtablemaker@gmail.com` to the `qsub` call
    - [see note below for TopHat timings]
* simulations: in `run_sim_directFPKM_geuvadis.sh`
    - line 50: add `-m e -M youremail+simtiming@gmail.com` to the `qsub` call
    - line 74: add `-m e -M youremail+stiming@gmail.com` to the `qsub` call
    - line 110: add `-m e -M youremail+stiming@gmail.com` to the `qsub` call

#### GEUVADIS
I used the `analyze_efficiency.py` script to analyze the Cufflinks and Tablemaker runs from GEUVADIS:
```
python analyze_efficiency.py --email myemail@gmail.com --alias myemail+gcufflinks@gmail.com --limit 1000 --outfile cufflinks_times.txt
python analyze_efficiency.py --email myemail@gmail.com --alias myemail+gtablemaker@gmail.com --limit 1000 --outfile tablemaker_times.txt

```
Learn about `analyze_efficiency.py` and its dependencies [here](https://github.com/alyssafrazee/efficiency_analytics) and [here](http://alyssafrazee.com/efficiency-analytics.html). This repo contains `cufflinks_times.txt` and `tablemaker_times_all.txt` (the `time` column here is the `walltime` column output from `analyze_efficiency.py`)

The TopHat runtimes were a little trickier because the TopHat scripts also included the time spent downloading reads with `wget`. So instead of scraping emails, for this, I parsed the last line of TopHat's log file (i.e. its output to stderr), which indicates elapsed time. I did this with the `tophat_times_geuv.py` script, which creates the `tophat_times.txt` file.

#### simulated data
For the simulated data times (text in the "Computational time comparisons" section of the manuscript), I ran `sim_times_tophatcufflinksbg.py` to obtain `simtimes.txt`.  Like `analyze_efficiency.py`, this scrapes my email account for SGE job completion notifications.

#### Cuffdiff and Cuffquant
The simulated data shell scripts output Cuffdiff start and end times (see lines 138-142 in `run_sim_p00.sh` and lines 137-141 in `run_sim_directFPKM_geuvadis.sh`), which is where we saw the 75-minute result for Cuffdiff on simulated data in the TopHat-Cufflinks-Cuffdiff pipeline. For the 23-minute result for Cuffdiff (run after Cuffquant), we ran  `cuffdiff_fpkm_quant.sh` (available above) and got this completion email:
```
Job 1994104 (cuffdiff_fpkm_quant.sh) Complete
 User             = afrazee
 Queue            = jabba.q@compute-0-47.local
 Host             = compute-0-47.local
 Start Time       = 03/26/2014 12:48:39
 End Time         = 03/26/2014 13:12:11
 User Time        = 00:31:36
 System Time      = 00:00:19
 Wallclock Time   = 00:23:32
 CPU              = 00:31:56
 Max vmem         = 7.239G
 Exit Status      = 0
```
Cuffquant was run using the `run_cuffquant_fpkm.sh` script, where environment variables should be set the same way as they are in the `run_sim_directFPKM_geuvadis.sh` script in the [simulations folder](https://github.com/alyssafrazee/ballgown_code/tree/master/simulations). To get Cuffquant times, I again used `analyze_efficiency.py` to scrape my email, resulting in the `cuffquant_times.txt` file.

### producing results in the paper
The script `timing_results.R` produces the results in the manuscript, including Figure 5. The text results (in order) are:
* 3 minutes/sample for Tablemaker on simulated data
* 4 minutes/sample for Cuffquant on simulated data
* 23 minutes for Cuffdiff after Cuffquant (see above)
* 75 minutes for Cuffdiff directly after Cuffmerge
* 2 hours/sample for TopHat on simulated data
* 5 minutes/sample for Cufflinks on simulated data
* median Tablemaker time per sample on GEUVADIS: 0.97 hours 
* IQR for Tablemaker times per sample on GEUVADIS: 0.24 hours

The `timing_results.R` script depends on `RSkittleBrewer` (for Figure 5's colors); to install:
```S
install.packages("devtools") #if needed
library(devtools)
install_github("RSkittleBrewer", "alyssafrazee")
```

All the numerical results are commented in the code and should be reproducible given the data in this repo. 

Another quick reproducibility note: runtimes on your machine(s) will likely vary from the runtimes on our machines.







