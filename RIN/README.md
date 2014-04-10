## code for RIN analysis in ballgown manuscript

This code executes the analysis of how RNA quality ([RIN](http://en.wikipedia.org/wiki/RNA_integrity_number)) affects transcript expression presented in the [ballgown manuscript](http://biorxiv.org/content/early/2014/03/30/003665). Specifically, this code produces:

* Figure 3 (both panels)
* Figure 6d
* Supplementary Figure 2

### dependencies
To use this code, you will need:

* The ballgown and RSkittleBrewer R packages from GitHub: in R, run
```S
install.packages("devtools") #if needed
library(devtools)
install_github("ballgown", "alyssafrazee")
install_github("RSkittleBrewer", "alyssafrazee")
```
* The limma R package from Bioconductor: in R, run
```S
source("http://bioconductor.org/biocLite.R")
biocLite("limma")
```
* The GEUVADIS ballgown object (`geuvadisbg.rda`). Code to create this is in the [GEUVADIS_preprocessing folder](https://github.com/alyssafrazee/ballgown_code/tree/master/GEUVADIS_preprocessing) of this repo, or the object can be [directly downloaded](https://www.dropbox.com/s/kp5th9hgkq8ckom/geuvadisbg.rda).

### script
After installing all the dependencies, run the script `rin_analysis.R`. As long as `geuvadisbg.rda` is in the working directory, you don't need to change any paths in this script.