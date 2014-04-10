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

These scripts assume that `tophat`, `cufflinks`, `cuffmerge`, and `tablemaker` are all in your path. They also use the Sun Grid Engine (SGE) scheduling system to run lots of jobs at once (namely, they use `qsub` commands to submit batch jobs), so if you want to run this code but don't have SGE, the scripts will need to be modified.

### (1) organize phenotype and quality-control information

The raw RNA-seq reads from the GEUVADIS study are available from ENA (the European Nucleotide Archive), study accession number ERP001942 ([link](http://www.ebi.ac.uk/ena/data/view/ERP001942)). 

We needed to match read IDs to sample names in the [quality-control statistics file](https://www.dropbox.com/s/rg63qtuws2liz9r/GD667.QCstats.masterfile.txt), and we also needed HapMap/1000 Genomes population information for each sample. 

The code in `get_populations.py` matches read IDs to sample names using information from the [ENA site](http://www.ebi.ac.uk/ena/data/warehouse/filereport?accession=ERP001942&result=read_run&fields=study_accession,secondary_study_accession,sample_accession,secondary_sample_accession,experiment_accession,run_accession,scientific_name,instrument_model,library_layout,fastq_ftp,fastq_galaxy,submitted_ftp,submitted_galaxy,col_tax_id,col_scientific_name)
, and matches that information to population information using data from the [1000 Genomes site](ftp://ftp-trace.ncbi.nih.gov/1000genomes/ftp/sequence.index).

Run `python get_populations.py` to produce `pop_data_withuniqueid.txt`.

`pop_data_annot_whole.txt` is the same as `pop_data_withuniqueid.txt`, but it doesn't have a header, it doesn't have the `sample_id` column, and the `hapmap_id` column (column 2) uniquely identifies sequencing runs (e.g., for hapmap ID NA12760, `pop_data_annot_whole` labels its two sequencing runs as NA12760 and NA12760_2 in column 2, while `pop_data_withuniqueid.txt` labels both these runs NA12760 in the `hapmap_id` column). 

### (2) download and align sequencing reads
