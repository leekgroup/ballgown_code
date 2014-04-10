## code for processing the GEUVADIS RNA-seq dataset

### (0) get dependencies

To run this code, you will need:  
* the Ballgown R package: in R, run:
```S
install.packages("devtools") #if needed
install_github("ballgown", "alyssafrazee")
```
* Tablemaker, downloadable from the `tablemaker` subfolder of the [Ballgown GitHub repo](https://github.com/alyssafrazee/ballgown)
* [TopHat](http://tophat.cbcb.umd.edu/) and [Cufflinks](http://cufflinks.cbcb.umd.edu/) (the Cufflinks download includes both `cufflinks` and `cuffmerge`). 
* Python >= 2.5
* the UCSC hg19 Homo sapiens index download from [this page](http://tophat.cbcb.umd.edu/igenomes.shtml). 

These scripts assume that `tophat`, `cufflinks`, `cuffmerge`, and `tablemaker` are all in your path. They also use the Sun Grid Engine (SGE) scheduling system to run lots of jobs at once (namely, they use `qsub` commands to submit batch jobs), so if you want to run this code but don't have SGE, the scripts will need to be modified.

### (1) organize phenotype and quality-control information

The raw RNA-seq reads from the GEUVADIS study are available from ENA (the European Nucleotide Archive), study accession number ERP001942 ([link](http://www.ebi.ac.uk/ena/data/view/ERP001942)). 

We needed to match read IDs to sample names in the quality-control statistics file (`GD667.QCstats.masterfile.txt`), and we also needed HapMap/1000 Genomes population information for each sample. 

The code in `get_populations.py` matches read IDs to sample names using information from the [ENA site](http://www.ebi.ac.uk/ena/data/warehouse/filereport?accession=ERP001942&result=read_run&fields=study_accession,secondary_study_accession,sample_accession,secondary_sample_accession,experiment_accession,run_accession,scientific_name,instrument_model,library_layout,fastq_ftp,fastq_galaxy,submitted_ftp,submitted_galaxy,col_tax_id,col_scientific_name)
, and matches that information to population information using data from the [1000 Genomes site](ftp://ftp-trace.ncbi.nih.gov/1000genomes/ftp/sequence.index).

Run `python get_populations.py` to produce `pop_data_withuniqueid.txt`.

`pop_data_annot_whole.txt` is the same as `pop_data_withuniqueid.txt`, but it doesn't have a header, it doesn't have the `sample_id` column, and the `hapmap_id` column (column 2) uniquely identifies sequencing runs (e.g., for hapmap ID NA12760, `pop_data_annot_whole` labels its two sequencing runs as NA12760 and NA12760_2 in column 2, while `pop_data_withuniqueid.txt` labels both these runs NA12760 in the `hapmap_id` column). 

### (2) download and align sequencing reads
Change variables in `run_tophat.sh`:  
* `ANNOTATIONPATH` should point to a directory containing the "Homo_sapiens" folder from the hg19 [iGenomes index download](http://tophat.cbcb.umd.edu/igenomes.shtml).
* `DATADIR` should point to where you want the fastq files to go
* `BDIR` should point to where you want the alignment files (BAM files) to be written. This should be a clean/empty folder.

Once these are changed, run `sh run_tophat.sh`. 

NB: One script per sample will be written and submitted using qsub. In other words, this script writes and submits 667 scripts.

### (3) assemble transcriptomes
Wait for all scripts submitted in step (2) to finish running.

Change variables in `run_cufflinks.sh`:  
* `BDIR` should be the same `BDIR` from `run_tophat.sh` (points to where alignment files were written)
* `CDIR` should point to where you want the transcript assemblies to be written

Then run `sh run_cufflinks.sh`. Again, NB: one script per sample (667 samples) will be written and submitted using qsub.

### (4) merge sample-specific assemblies
Wait for all scripts submitted in step (3) to finish running.

Change variables in `run_cuffmerge.sh`:  
* `ANNOTATIONPATH` should be the same as it is in `run_tophat.sh`
* `CDIR` should be the same as it is in `run_cufflinks.sh`
* `OUTDIR` should point to where you want the merged assembly to be written

Then run the `run_cuffmerge.sh` script. (I did `qsub cuffmerge.sh` since it will likely take a few hours).

### (5) calculate/organize expression measurements for assembly
When step (4) is finished (i.e. when `cuffmerge` has finished running), run `tablemaker` on all samples.

Change variables in `run_tablemaker.sh`:  
* `BDIR` should be the same as it is in `run_tophat.sh` and `run_cufflinks.sh` (points to where alignment files were written)
* `MASM` points to the `merged.gtf` file output by `cuffmerge` (likely `$OUTDIR/merged.gtf`, where `OUTDIR` was defined in `run_cuffmerge.sh`)
* `BGOUTDIR` should be the path to a folder where you want `tablemaker` output to be written, plus `/$SAMPLE` (i.e., `$SAMPLE` where it currently is)

Then run `sh run_tablemaker.sh`. As before, NB: one script per sample (667 samples) will be written and submitted using qsub.

### (6) create the GEUVADIS ballgown object
Code to do this is in `make_bgobj.R`. 

Change some variables in this script:  
* `dataDir` should point to the folder containing `tablemaker` output. Typically this will be the path in `BGOUTDIR` in `run_tablemaker.sh`, up to but not including `$SAMPLE`. There should be a `/` at the end of `dataDir`.
* `bamDir` should be the same as `BDIR` in `run_tophat.sh`, `run_cufflinks.sh`, and `run_tablemaker.sh` (with `/` at the end)

Then run `Rscript make_bgobj.R` or `R CMD BATCH make_bgobj.R`. (Making the ballgown object will likely take about two hours, so it's probably best to run it as a non-interactive batch job).




