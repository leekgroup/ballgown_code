## code for RIN analysis in ballgown manuscript

This code executes the analysis of how RNA quality ([RIN](http://en.wikipedia.org/wiki/RNA_integrity_number)) affects transcript expression presented in the [ballgown manuscript](http://biorxiv.org/content/early/2014/03/30/003665). Specifically, this code produces:

* Figure 3 (both panels)
* Figure 6d
* Supplementary Figure 2

### dependencies
To use this code, you will need:

* The RSkittleBrewer R package from GitHub, and the ballgown R package (version >= 0.99.3) from Bioconductor: in R, run
```S
install.packages("devtools") #if needed
library(devtools)
source("http://bioconductor.org/biocLite.R")
biocLite("ballgown")
```
* Two of the GEUVADIS ballgown objects: [`fpkm.rda`](http://files.figshare.com/1625419/fpkm.rda) and [`cov.rda`](http://files.figshare.com/1625417/cov.rda). Code to create these objects is in the [GEUVADIS_preprocessing folder](https://github.com/alyssafrazee/ballgown_code/tree/master/GEUVADIS_preprocessing) of this repo.

### script
After installing all the dependencies, knit the `RIN_analysis.Rmd` file as you would normally knit a `.Rmd` file (e.g., with the `knit()` command in R, or using the "knit to HTML" or "knit to PDF" options in RStudio). Make sure `fpkm.rda` and `cov.rda` are in the working directory.