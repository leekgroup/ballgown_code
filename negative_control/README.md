## code for negative control experiment in Ballgown manuscript

This code executes the negative control experiment presented in the [ballgown manuscript](http://biorxiv.org/content/early/2014/09/05/003665). Specifically, this code creates:

* Figure 1a
* Supplementary Figure 3 (both panels)
* Supplementary Figure 4

You'll need Cuffdiff output to produce this code. If you want, you can download mine:
* make a folder called `cuffdiff` in your working directory
* put `isoform_exp.diff` in that folder (if you cloned this repo, the cuffdiff folder and this file are already there)
* download [isoforms.read_group_tracking](https://www.dropbox.com/s/uzk9jh8bssgild0/isoforms.read_group_tracking.gz?dl=0), unzip it, and put that in the `cuffdiff` folder too.

If you'd rather run Cuffdiff yourself, you can use my script, `cuffdiff.sh`. It downloads the required GEUVADIS BAM files automatically into the working directory (with wget). You'll need quite a lot of disk space for them (on the order of ~300G). You'll also need the `merged.gtf` file from running the [GEUVADIS preprocessing code](https://github.com/alyssafrazee/ballgown_code/tree/master/GEUVADIS_preprocessing). You can download/unzip merged.gtf from this very repo, if you'd prefer. You'll also need cuffdiff in your path. You'll also need the `random_groups.txt` file from this repo, which I created with code inside the Rmd file. _Running Cuffdiff will take lots of computing power: it took me 69 hours and 148G of memory_. 

You'll also need:

* [fpkm.rda](http://files.figshare.com/1625419/fpkm.rda) and [rcount.rda](http://files.figshare.com/1625424/rcount.rda) (processed GEUVADIS Ballgown objects; created with code [here](https://github.com/alyssafrazee/ballgown_code/tree/master/GEUVADIS_preprocessing))
* The [ballgown](http://www.bioconductor.org/packages/release/bioc/html/ballgown.html) and [EdgeR](http://www.bioconductor.org/packages/release/bioc/html/edgeR.html) R packages from Bioconductor.

Once you have the required output (Cuffdiff files, rda files, and required R packages), you can just [knit](http://yihui.name/knitr/) the file `negative_control.Rmd`. 

You can view my knitted html output [here](http://htmlpreview.github.io/?https://github.com/alyssafrazee/ballgown_code/blob/master/negative_control/negative_control.html). 