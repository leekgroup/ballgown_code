Code for analysis in Ballgown manuscript
=============

Pardon our dust!  We're cleaning up our scripts right now, but we'll be pushing all the code to this repo within the next few days.

## scripts/code
Scripts for each analysis section are available in the relevant subfolder.

### simulations
All simulation results from the paper were produced with scripts in this folder. Simulation results include:  
* Figure 2c and 2d
* Figure 6a, 6b, and 6c
* Supplementary Figure 1 (both panels)

This code also gives numerical results presented in the "Statistical significance comparisons" section of the paper.

### InSilicoDB
The manuscript examines statistical significance results from two datasets downloaded from [InSilico DB](https://insilicodb.com/). This analysis includes Figure 2a and 2b, as well as numerical results in the "Statistical significance comparisons" section.

### GEUVADIS_preprocessing
The manuscript includes a re-analysis of the [GEUVADIS RNA-sequencing dataset](http://www.geuvadis.org/web/geuvadis/rnaseq-project). This folder includes scripts for downloading and aligning reads, assembling the transcriptome, estimating transcript abundances, and organizing the expression measurements into the GEUVADIS ballgown object (see "GEUVADIS ballgown object" in the data section). The ballgown object was used for the eQTL and RIN analyses.

### RIN
Analysis investigating the relationship between RNA quality (RIN) and transcript expression was done with the script in this folder. This analysis includes:  
* Figure 3 (both panels)
* Figure 6d
* Supplementary Figure 2

This code also gives the numerical results in the "Analysis of quantitative covariates" (subsection of "Flexibility of statistical models") section of the manuscript.

### eQTL


## data
Data is currently available on Dropbox:

#### Results of MatrixEQTL for GEUVADIS 

https://www.dropbox.com/s/c3r3bgsuhs2s07g/eQTL_GEUVADIS_imputed_list_cis_1e6.rda

#### Results from MatrixEQTL analysis annotated with Ensembl.

https://www.dropbox.com/s/z3eb39zbq44ydov/eQTL_GEUVADIS_imputed_list_cis_1e6_annotated.rda

#### Filtered GEUVADIS genotypes

https://www.dropbox.com/s/xb58k5kedj8ji35/GEUVADIS_genotypeData_maf05.rda

#### Top 3PCS from Genotype Data

https://www.dropbox.com/s/g8d9tyc6hky5nwu/plink.mds

#### Annotation files

https://www.dropbox.com/s/woacfjxql7gxhnt/pop_data_withuniqueid.txt
https://www.dropbox.com/s/rg63qtuws2liz9r/GD667.QCstats.masterfile.txt

#### GEUVADIS ballgown object

https://www.dropbox.com/s/kp5th9hgkq8ckom/geuvadisbg.rda



