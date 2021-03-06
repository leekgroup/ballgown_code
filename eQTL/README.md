## code for eQTL analysis in ballgown manuscript

This code performs the eQTL (Expression Quantitative Trait Loci) analysis in the [Ballgown manuscript](http://biorxiv.org/content/early/2014/09/05/003665).

Specifically, this code (`eqtl-analysis-geuvadis.R`) produces:  
* Figure 1e-f
* Supplementary Figure 9 
* Numerical results in the section of the manuscript beginning "To further illustrate the flexibility of using the post-processed Ballgown data..." (the eQTL section) and in Supplementary Note 8

### data and dependencies
Running `eqtl-analysis-geuvadis.R` requires:
  1.  Either running `get_genotypes.R` or downloading what would be output from it:
    - Filtered GEUVADIS genotypes (remove SNPs with minor allele frequency less than 5%): [GEUVADIS_genotypeData_maf05.rda](https://www.dropbox.com/s/xb58k5kedj8ji35/GEUVADIS_genotypeData_maf05.rda)  
    - Top 3 principal components from genotype data: [plink.mds](https://www.
dropbox.com/s/g8d9tyc6hky5nwu/plink.mds)
  2.  Either running `fit_eqtl_model.R` or downloading what would be output from it:
    - MatrixEQTL results: [eQTL_GEUVADIS_imputed_list_cis_1e6.rda](https://www.dropbox.com/s/c3r3bgsuhs2s07g/eQTL_GEUVADIS_imputed_list_cis_1e6.rda)
    - Annotated MatrixEQTL results: [eQTL_GEUVADIS_imputed_list_cis_1e6_annotated.rda](http://files.figshare.com/1645064/eQTL_GEUVADIS_imputed_list_cis_1e6_annotated.rda)
    - Annotated MatrixEQTL results, significant eQTLs only: [sig_eQTL_GEUVADIS_imputed_list_cis_1e6_annotated.rda](https://www.dropbox.com/s/zvq44jo3srhbdyq/sig_eQTL_GEUVADIS_imputed_list_cis_1e6_annotated.rda)
  3.  Finally running `eqtl-analysis-geuvadis.R`. 

===============================

To run `get_genotypes.R`, you will need:  
* GEUVADIS genotype data. We recommend creating a folder called `Genotypes` in your working directory, changing to the `Genotypes` folder, and running:
```
wget ftp://ftp.ebi.ac.uk/pub/databases/microarray/data/experiment/GEUV/E-GEUV-1/genotypes/*
```
(Scripts assume the genotypes are in a folder called `Genotypes` in your working directory).  
* [VCFtools](http://vcftools.sourceforge.net/) -- the `vcftools` executable should be in your path  
* [PLINK](http://pngu.mgh.harvard.edu/~purcell/plink/) -- the `plink` executable should be in your path  
* the `multicore` R package. To install, start R and run:
```S
install.packages("multicore")
```  
* **NOTE**: this script assumes you have 6 cores on a single machine available to run code on. The `mclapply` line will need to be modified if this is not the case.


Put these files in the `Genotypes` subdirectory of your working directory.

====================
To run `fit_eqtl_model.R`, you will need:
* the Ballgown and MatrixEQTL R packages. To install, start R and run:
```S
install.packages("MatrixEQTL")
install.packages("devtools") #if needed
install_github("ballgown", "alyssafrazee", ref="alpha")
```
* the GEUVADIS ballgown object: this can be downloaded [here](https://www.dropbox.com/s/kp5th9hgkq8ckom/geuvadisbg.rda) or created with the code in the [GEUVADIS_preprocessing subfolder](https://github.com/alyssafrazee/ballgown_code/tree/master/GEUVADIS_preprocessing) of this repo.  
* `GD667.QCstats.masterfile.txt` (quality control information) and `pop_data_withuniqueid.txt` (population information), both available in this repo. Code for creating `pop_data_withuniqueid.txt` is in the [GEUVADIS_preprocessing subfolder](https://github.com/alyssafrazee/ballgown_code/tree/master/GEUVADIS_preprocessing)
* output from `get_genotypes.R` (or relevant downloaded output) in the `Genotypes` subdirectory of your working directory
* Ensembl gene annotations, available [at this link](https://www.dropbox.com/s/4gd05ghjkurj170/Homo_sapiens.GRCh37.73_chrPrefix.gtf) as `Homo_sapiens.GRCh37.73_chrPrefix.gtf`. This file is the same as the file here: `ftp://ftp.ensembl.org/pub/release-73/gtf/homo_sapiens/Homo_sapiens.GRCh37.73.gtf.gz`, but with the prefix `chr` appended to all chromosome names.

=================
To run `eqtl-analysis-geuvadis.R`, you will need:
* the Ballgown, MatrixEQTL, and RSkittleBrewer R packages. To install, start R and run:
```S
install.packages("MatrixEQTL")
install.packages("devtools") #if needed
install_github("ballgown", "alyssafrazee")
install_github("RSkittleBrewer", "alyssafrazee")
```
* output from `fit_eqtl_model.R` and `get_genotypes.R` (or relevant downloaded output) in working directory:
    - `GEUVADIS_genotypeData_maf05.rda` 
    - `eQTL_GEUVADIS_imputed_list_cis_1e6.rda`
    - `sig_eQTL_GEUVADIS_imputed_list_cis_1e6_annotated.rda`
* eQTL results from the published GEUVADIS paper, available here or downloadable from [this link](http://www.ebi.ac.uk/arrayexpress/files/E-GEUV-1/analysis_results/): 
    - `EUR373.trratio.cis.FDR5.all.rs137.txt`
    - `YRI89.trratio.cis.FDR5.all.rs137.txt`
* the GEUVADIS ballgown object: this can be downloaded [here](https://www.dropbox.com/s/kp5th9hgkq8ckom/geuvadisbg.rda) or created with the code in the [GEUVADIS_preprocessing subfolder](https://github.com/alyssafrazee/ballgown_code/tree/master/GEUVADIS_preprocessing) of this repo.

================================

Once all dependencies are downloaded, run `eqtl-analysis-geuvadis.R` to obtain the manuscript's results.



