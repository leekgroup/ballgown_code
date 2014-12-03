## code for positive control experiment in Ballgown manuscript

This code executes the positive control (Y-chromosome) experiment in the [ballgown manuscript](http://biorxiv.org/content/early/2014/09/05/003665). Specifically, this code creates:

* Figure 1b
* Supplementary Figure 4

You will need Cuffdiff output to run this code. The file `isoform_exp.diff` is available in this repo, and you can download `Y_isoforms.read_group_tracking.gz` [at this link](https://www.dropbox.com/s/jxesfrketa0iwgx/Y_isoforms.read_group_tracking.gz?dl=0).

If you want to run Cuffdiff yourself, my script is here (`cuffdiff.sh`). It downloads the required GEUVADIS BAM files into the working directory. You'll need about 300G of disk space for this. You will also need the merged.gtf file created using the [GEUVADIS preprocessing code](https://github.com/alyssafrazee/ballgown_code/tree/master/GEUVADIS_preprocessing). You can download that from the `negative_control` experiment folder in this repo (i.e., [here](https://github.com/alyssafrazee/ballgown_code/blob/master/negative_control/merged.gtf.gz)). Unzip before using. Finally, you'll need the `sex_info.txt` file from this repo, and you'll need Cuffdiff in your path. 

You will also need:

* [fpkm.rda](http://files.figshare.com/1625419/fpkm.rda), the processed GEUVADIS fpkm object created with [this code](https://github.com/alyssafrazee/ballgown_code/tree/master/GEUVADIS_preprocessing). 
* The [ballgown](http://www.bioconductor.org/packages/release/bioc/html/ballgown.html) and [EBSeq](http://www.bioconductor.org/packages/release/bioc/html/EBSeq.html) R packages (from Bioconductor) and the [reshape2](http://cran.r-project.org/web/packages/reshape2/index.html) R package from CRAN.

Once you have the required files, you can just [knit](http://yihui.name/knitr/) the file `positive_control.Rmd`. 

You can view my knitted html output [here](http://htmlpreview.github.io/?https://github.com/alyssafrazee/ballgown_code/blob/master/positive_control/positive_control.html). 