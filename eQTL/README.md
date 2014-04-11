## code for eQTL analysis in ballgown manuscript

This code performs the eQTL (Expression Quantitative Trait Loci) analysis in the [Ballgown manuscript](http://biorxiv.org/content/early/2014/03/30/003665).

Specifically, this code (`eqtl-analysis-geuvadis.R`) produces:  
* Figure 4 (both panels)
* Supplementary Figure 3 (both panels)
* Numerical results in the "Expression quantitative trait locus analysis" section of the main manuscript (subsection of "Flexibility of statisticsl models") and in the "eQTL analysis" section of the supplement (subsection of "Data Analyses").

### data and dependencies
Running `eqtl-analysis-geuvadis.R` requires:
  1.  Either running `get_genotypes.R` or downloading what would be output from it:
    - Filtered GEUVADIS genotypes (remove SNPs with minor allele frequency less than 5%): [GEUVADIS_genotypeData_maf05.rda](https://www.dropbox.com/s/xb58k5kedj8ji35/GEUVADIS_genotypeData_maf05.rda)  
    - Top 3 principal components from genotype data: [plink.mds](https://www.
dropbox.com/s/g8d9tyc6hky5nwu/plink.mds)
  2.  Either running `fit_eqtl_model.R` or downloading what would be output from it:
    - MatrixEQTL results: [eQTL_GEUVADIS_imputed_list_cis_1e6.rda](https://www.dropbox.com/s/c3r3bgsuhs2s07g/eQTL_GEUVADIS_imputed_list_cis_1e6.rda)
    - Annotated MatrixEQTL results: [eQTL_GEUVADIS_imputed_list_cis_1e6_annotated.rda](https://www.dropbox.com/s/z3eb39zbq44ydov/eQTL_GEUVADIS_imputed_list_cis_1e6_annotated.rda)
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
install_github("ballgown", "alyssafrazee")
```
* the GEUVADIS ballgown object: this can be downloaded [here](https://www.dropbox.com/s/kp5th9hgkq8ckom/geuvadisbg.rda) or created with the code in the [GEUVADIS_preprocessing subfolder](https://github.com/alyssafrazee/ballgown_code/tree/master/GEUVADIS_preprocessing) of this repo.  
* `GD667.QCstats.masterfile.txt` (quality control information) and `pop_data_withuniqueid.txt` (population information), both available in this repo. Code for creating `pop_data_withuniqueid.txt` is in the [GEUVADIS_preprocessing subfolder](https://github.com/alyssafrazee/ballgown_code/tree/master/GEUVADIS_preprocessing)
* output from `get_genotypes.R` (or relevant downloaded output) in the `Genotypes` subdirectory of your working directory
* Ensembl gene annotations, available (soon) [at this link]() as `Homo_sapiens.GRCh37.73_chrPrefix.gtf`. This file is the same as the file here: `ftp://ftp.ensembl.org/pub/release-73/gtf/homo_sapiens/Homo_sapiens.GRCh37.73.gtf.gz`, but with the prefix `chr` appended to all chromosome names.

=================
To run `eqtl-analysis-geuvadis.R`, you will need:
* the Ballgown, MatrixEQTL, and RSkittleBrewer R packages. To install, start R and run:
```S
install.packages("MatrixEQTL")
install.packages("devtools") #if needed
install_github("ballgown", "alyssafrazee")
install_github("RSkittleBrewer", "alyssafrazee")
```
* output from `fit_eqtl_model.R` (or relevant downloaded output) -- should be two `.rda` files -- in working directory
* eQTL results from the published GEUVADIS paper, available here: 
    - `EUR373.trratio.cis.FDR5.all.rs137.txt`
    - `YRI89.trratio.cis.FDR5.all.rs137.txt`
* the GEUVADIS ballgown object: this can be downloaded [here](https://www.dropbox.com/s/kp5th9hgkq8ckom/geuvadisbg.rda) or created with the code in the [GEUVADIS_preprocessing subfolder](https://github.com/alyssafrazee/ballgown_code/tree/master/GEUVADIS_preprocessing) of this repo.
* 





### analysis steps  
  1. Run `get_genotypes.R`, or download `GEUVADIS_genotypeData_maf05.rda` and `plink.mds`  

_hey_ 

