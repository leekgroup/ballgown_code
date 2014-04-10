## code for eQTL analysis in ballgown manuscript

This code performs the eQTL (Expression Quantitative Trait Loci) analysis in the [Ballgown manuscript](http://biorxiv.org/content/early/2014/03/30/003665).

### data and dependencies
To run `get_genotypes.R`, you will need:  
* GEUVADIS genotype data. We recommend creating a folder called `Genotypes` in your working directory, changing to the `Genotypes` folder, and running:
```
wget ftp://ftp.ebi.ac.uk/pub/databases/microarray/data/experiment/GEUV/E-GEUV-1/genotypes/*
```
(Scripts assume the genotypes are in a folder called `Genotypes` in your working directory).  
* [VCFtools](http://vcftools.sourceforge.net/) -- the `vcftools` executable should be in your path  
* [PLINK](http://pngu.mgh.harvard.edu/~purcell/plink/) -- the `plink` executable should be in your path  
* the `multicore` R package. To install, start R and run:
```
install.packages("multicore")
```  
* Related to the multicore package: the code assumes you have 6 cores on a single machine available to run code on. The `mclapply` line in this script will need to be modified if this is not the case.

You can also just download what would be output from `get_genotypes.R`:
* Filtered GEUVADIS genotypes (remove SNPs with minor allele frequency less than 5%): [GEUVADIS_genotypeData_maf05.rda](https://www.dropbox.com/s/xb58k5kedj8ji35/GEUVADIS_genotypeData_maf05.rda)  
* Top 3 principal components from genotype data: [plink.mds](https://www.
dropbox.com/s/g8d9tyc6hky5nwu/plink.mds)

Put these files in the `Genotypes` subdirectory of your working directory.

====================
To run `geuvadis_cis_eqtl-pvaluehist.R`, you will need:
* the Ballgown and MatrixEQTL R packages. To install, start R and run:
```S
install.packages("MatrixEQTL")
install.packages("devtools") #if needed
install_github("ballgown", "alyssafrazee")
```
* the GEUVADIS ballgown object: this can be downloaded [here]() or created with the code in the [GEUVADIS_preprocessing subfolder](https://github.com/alyssafrazee/ballgown_code/tree/master/GEUVADIS_preprocessing) of this repo.  
* `GD667.QCstats.masterfile.txt` (quality control information) and `pop_data_withuniqueid.txt` (population information), both available in this repo. Code for creating `pop_data_withuniqueid.txt` is in the [GEUVADIS_preprocessing subfolder](https://github.com/alyssafrazee/ballgown_code/tree/master/GEUVADIS_preprocessing)
* output from `get_genotypes.R` (or relevant downloaded output) in the `Genotypes` subdirectory of your working directory
* Ensembl gene annotations (we used version 73), available in this repo [SOON] as `Homo_sapiens.GRCh37.73_chrPrefix.gtf`. This file is the same as this file: `ftp://ftp.ensembl.org/pub/release-73/gtf/homo_sapiens/Homo_sapiens.GRCh37.73.gtf.gz`, but has chromosomes labeled with the `chr` prefix.


### analysis steps  
  1. Run `get_genotypes.R`, or download `GEUVADIS_genotypeData_maf05.rda` and `plink.mds`  

