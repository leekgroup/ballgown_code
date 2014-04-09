## getting information from GEUVADIS samples

The raw RNA-seq reads from the GEUVADIS study are available from ENA (the European Nucleotide Archive), study accession number ERP001942 ([link](http://www.ebi.ac.uk/ena/data/view/ERP001942)). 

We needed to match read IDs to sample names in the [quality-control statistics file](https://www.dropbox.com/s/rg63qtuws2liz9r/GD667.QCstats.masterfile.txt), and we also needed HapMap/1000 Genomes population information for each sample. 

The code in `get_populations.py` matches read IDs to sample names using information from the [ENA site](http://www.ebi.ac.uk/ena/data/warehouse/filereport?accession=ERP001942&result=read_run&fields=study_accession,secondary_study_accession,sample_accession,secondary_sample_accession,experiment_accession,run_accession,scientific_name,instrument_model,library_layout,fastq_ftp,fastq_galaxy,submitted_ftp,submitted_galaxy,col_tax_id,col_scientific_name)
), and matches that information to population information using data from the [1000 Genomes site](ftp://ftp-trace.ncbi.nih.gov/1000genomes/ftp/sequence.index).

Running `get_populations.py` produces `pop_data_withuniqueid.txt`, which is used in later analyses (eQTL and RIN analyses).