Code for analysis in Ballgown manuscript
=============

Data and code to reproduce the analyses in the [Ballgown manuscript](http://biorxiv.org/content/early/2014/03/30/003665) is available in this repository. Larger data files are hosted externally, but this repository contains links.

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
Analysis of Expression Quantitative Trait Loci in the GEUVADIS dataset. Specifically this analysis includes:
* Figure 4 (both panels)
* Supplementary Figure 3 (both panels)
* Numerical results in the "Expression quantitative trait locus analysis" section of the main manuscript (subsection of "Flexibility of statistical models") and in the "eQTL analysis" section of the supplement (subsection of "Data Analyses").

### timing
Computational times for many of the analyses presented in the manuscript. Specifically this folder includes code for:
* Figure 5 (all panels)
* All timing results in the "Computational time comparison" section 

## data
The following data is currently available on Dropbox. Other relevant data is stored in the subfolders. All Dropbox links are also referenced in subfolder README files.

* [Results of MatrixEQTL for GEUVADIS](https://www.dropbox.com/s/c3r3bgsuhs2s07g/eQTL_GEUVADIS_imputed_list_cis_1e6.rda) (.rda)
* [Results from MatrixEQTL analysis annotated with Ensembl](https://www.dropbox.com/s/z3eb39zbq44ydov/eQTL_GEUVADIS_imputed_list_cis_1e6_annotated.rda) (.rda)
* [Filtered GEUVADIS genotypes](https://www.dropbox.com/s/xb58k5kedj8ji35/GEUVADIS_genotypeData_maf05.rda) (.rda)
* [Top 3 principal components from GEUVADIS genotype data](https://www.dropbox.com/s/g8d9tyc6hky5nwu/plink.mds) (.mds; created with PLINK)
* [GEUVADIS quality-control statistics](https://www.dropbox.com/s/rg63qtuws2liz9r/GD667.QCstats.masterfile.txt) (.txt)
* [GEUVADIS population information](https://www.dropbox.com/s/woacfjxql7gxhnt/pop_data_withuniqueid.txt) (.txt) - matched to IDs in quality-control statistics file
* [GEUVADIS ballgown object](https://www.dropbox.com/s/kp5th9hgkq8ckom/geuvadisbg.rda) (.rda)
* [Ensembl Genes from human chr1-22,X,Y -- iGenomes](https://www.dropbox.com/s/89iaagrkwlu0tbs/genes-clean.gtf) (.gtf)
* [Ensembl Genes with chromosome names prefixed with "chr"](https://www.dropbox.com/s/4gd05ghjkurj170/Homo_sapiens.GRCh37.73_chrPrefix.gtf)
* [Simulated RNA-seq reads: differential expression at FPKM level](https://www.dropbox.com/s/bqrusc1cpq51ecq/lognormalgeuvadis.zip)
* [Simulated RNA-seq reads: differential expression at read-count level](https://www.dropbox.com/s/2e5gmasapnnzn29/nbp0.zip)
* [Developmental cell types dataset, downloaded from InSilico DB](https://www.dropbox.com/s/b4d44s7vtpzb4im/GSE36552GPL11154_DGE_RNASeq_04ec2b6a46a9ddb8ef2083b9d8ba4e3c.tgz)
* [Adenocarcinoma dataset, downloaded from InSilico DB](https://www.dropbox.com/s/ql7kb94fx7c5e44/GSE37764GPL10999_DGE_RNASeq_a9dc2c94672e4a51c036c76be9508164.tgz)

