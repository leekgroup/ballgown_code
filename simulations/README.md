## code for differential expression simulations

This code executes the simulations presented in the [ballgown manuscript](http://biorxiv.org/content/early/2014/03/30/003665.full-text.pdf+html). 

### two simulations
Two separate simulation scenarios are presented in the manuscript. 

1. The first scenario (described in the main manuscript) involves setting each transcript's expression level using FPKM, and accordingly, adding differential expression at the FPKM level. In other words, transcripts differentially expressed at 6x fold change had an average FPKM that was 6x greater in the overexpressed group. The number of reads to generate from each transcript was then calculated by multiplying the FPKM by the transcript length (in kilobases) and by a library size factor (in millions of reads). 

2. The second scenario (described in the manuscript supplement) involves drawing the number of reads to generate from each transcript from a negative binomial distribution. The transcript's length has no effect on the number of reads simulated from it. Scripts for this scenario are 

Specific details about parameters chosen for these simulations are available in the [manuscript supplement](http://biorxiv.org/content/biorxiv/suppl/2014/03/30/003665.DC1/003665-1.pdf), Section 3 (Simulation studies), and all code is available in this folder.

The scripts `run_sim_directFPKM_geuvadis.sh` and `simReads_FPKM_direct_geuvadis.R` belong to scenario #1. The scripts `run_sim_p00.sh` and `sim_NB_p0.R` belong to scenario #2. 

### how to use this code

#### (0) get dependencies
This code depends on R and the Rscript command line utility, the Biostrings, Ballgown, and Polyester R packages, and Python >=2.5. We ran all code on Linux.

To download Biostrings: in R, run:
```S
source("http://bioconductor.org/biocLite.R")
biocLite("Biostrings")
```

To download Ballgown and Polyester: in R, run:
```S
install.packages("devtools") #if needed
install_github("ballgown", "alyssafrazee")
install_github("ballgown", "alyssafrazee", subdir="polyester")
```

Additionally, we relied heavily on the Sun Grid Engine (SGE) scheduling system when running this pipeline, since this is what our department uses to schedule batch cluster jobs. In particular, the shell scripts in this folder contain `qsub` commands, indicating that a script is being submitted to the cluster to be run, so these lines will have to be modified if you want to run this code without using SGE. 

Finally, you will need [TopHat](http://tophat.cbcb.umd.edu/) (for the paper, we used version 2.0.9), [Cufflinks](http://cufflinks.cbcb.umd.edu/manual.html) (we used version 2.1.1), and the tablemaker binary (available in the [main Ballgown repository](https://github.com/alyssafrazee/ballgown)). These scripts assume "tophat" is in your path. See step (4) for more info on where we assume Cufflinks/Tablemaker are installed.

#### (1) get transcripts to simulate from
We simulated reads from human chromosome 22, Ensembl version 74. All transcripts can be downloaded [from this link](ftp://ftp.ensembl.org/pub/release-74/fasta/homo_sapiens/cdna/Homo_sapiens.GRCh37.74.cdna.all.fa.gz). Download this file, un-tar, and un-zip it, then run `get_chr22.R` to subset to chromsome 22. This produces `ensembl_chr22.fa`.

#### (2) get annotation files
We used Illumina's iGenomes annotation files, available at [this link](http://tophat.cbcb.umd.edu/igenomes.shtml). Specifically, we used the Ensembl annotation (first link on the page). The `genes.gtf` file (located in the `Annotation/Genes` subfolder) was cleaned with the `clean_genes.R` script to produce our annotation file, `genes-clean.gtf`. This gtf file contains only chromosomes 1-22, X, and Y (the clean_genes script removes all others). 

`genes-clean.gtf` will soon be available [here]().

The `ANNOTATIONPATH` variable in the shell scripts points to the folder containing the `Homo_Sapiens` directory that comes with the iGenomes index download.

#### (3) pre-build a transcriptome for TopHat
During TopHat runs in the simulations, we aligned first to the transcriptome, then to the genome (i.e., we used TopHat's `-G` option). We pre-built a transcriptome index and used that build for all TopHat runs to avoid re-building every time. A script plus small dummy reads used to build the transcriptome index are in the `tophat_transcriptome` subfolder. The `ANNOTATIONPATH` environment variable should be the same as it is in the shell scripts in the main (`simulations`) directory.

#### (4) run the shell script starting with `run_sim`
i.e., run `run_sim_directFPKM_geuvadis.sh` or `run_sim_p00.sh`. 

You will need to edit some environment variables at the beginning of these scripts:  
* `SOFTWAREPATH` should contain a folder called `cufflinks-2.1.1.Linux_x86_64` (containing `cufflinks`, `cuffmerge`)
* `$SOFTWAREPATH` should also contain the `tablemaker` binary
* `$ANNOTATIONPATH` should contain a folder called `Homo_Sapiens`, which comes with the Ensembl [iGenomes download](http://tophat.cbcb.umd.edu/igenomes.shtml)
* `$MAINDIR` only exists to reference `$FOLDERNAME`. All output from this pipeline will be written to `$FOLDERNAME`. **Make sure `$FOLDERNAME` is empty when you begin running the script.**
* `$PYTHON` should point to your python executable
* `Q` is the SGE queue to run the jobs on. Also note that line 2 of the script, the one beginning with `#$`, contains arguments to pass to SGE. Change these as needed for your system.


These scripts:  
* simulate reads with the R scripts prefixed with `simReads` (i.e, `simReads_FPKM_direct_geuvadis.R` for scenario #1, and `simReads_NB_p0.R` for scenario #2.) Read simulation is done with the `simulate_experiment_countmat` function in the [Polyester R package](https://github.com/alyssafrazee/ballgown/tree/master/polyester).
* run TopHat on each simulated sample
* Assemble transcripts with Cufflinks for each sample
* merge sample-specific assemblies with Cuffmerge
* run the Tablemaker binary (preprocessing step for Ballgown) for each sample
* run Cuffdiff on the experiment

#### (5) analyze output
All output will be organized in the folder specified in the `FOLDERNAME` variable at the beginning of the shell scripts. TopHat output will be in the `alignments` subfolder, Cufflinks in the `assemblies` folder, Cuffdiff in the `cuffdiff` folder, etc. Ballgown `.ctab` files will be in subfolders of the `ballgown` directory, so a ballgown object can be created in R as follows:

```S
# assuming working directory is $FOLDERNAME:
library(ballgown)
bgresults = ballgown(dataDir='ballgown', samplePattern='sample')
```

Code used to obtain results presented in the manuscript is in `sim_results.R`.

### simulated reads
Simulated reads used for the analysis in the paper will soon be available for download [here]().
 







