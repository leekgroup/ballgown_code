## code for InSilico DB analysis in ballgown manuscript

This code executes the analysis of two datasets from [InSilico DB](https://insilicodb.com/) presented in the [ballgown manuscript](http://biorxiv.org/content/early/2014/03/30/003665). Specifically, this code produces Figure 2a and 2b.

### dependencies

#### data from InSilico DB

We downloaded our data from InSilico DB on March 5, 2014. In case this data changes, we have uploaded freezes of the data we used:
* Accession number GSE36552, [developmental cell type dataset](https://www.dropbox.com/s/b4d44s7vtpzb4im/GSE36552GPL11154_DGE_RNASeq_04ec2b6a46a9ddb8ef2083b9d8ba4e3c.tgz)
* Accession number GSE37764, [adenocarcinoma dataset](https://www.dropbox.com/s/ql7kb94fx7c5e44/GSE37764GPL10999_DGE_RNASeq_a9dc2c94672e4a51c036c76be9508164.tgz)

To get these datasets:  
  1. Go to [insilicodb.com](https://insilicodb.com/)
  2. Create an account (free)  
  3. At the "Welcome to InSilico DB!" screen, click the "Try for free" button  
  4. This brings you to the InSilico DB search page. In the "Search query" box at the top, enter the accession number for the dataset you want.  
  5. Click the "Analyze (IGV - Download)" button on the result  
  6. Select "Differential Expression (Cuffdiff)"  
  7. Choose a differential expression keyword (there is only one choice for each dataset)  
  8. Click the "Download" button  
  9. Put the resulting tarball in your working directory, untar and unzip to extract the `.db` files referenced in the code.  

#### other dependencies
You will also need:  
* The sqldf, cummeRbund, and reshape packages from CRAN:
```S
install.packages('sqldf')
install.packages('cummeRbund')
install.packages('reshape')
```
* The ballgown R package (alpha version, from GitHub):
```S
install.packages('devtools') #if needed
library(devtools)
install_github('ballgown', 'alyssafrazee', ref='alpha')
```

### script
After getting the data and installing the required R libraries, run the script `insilicodb.R`. As long as you put the downloaded data into your working directory, you don't need to change any paths in this script.

### analysis with another Cuffdiff version

The data from InSilicoDb was analyzed with Cuffdiff 2.0.2. We also analyzed this data with Cuffdiff 2.2.1. (Scripts/description for that analysis are coming very, very soon). 

The R analysis for that data can be run by [knitting](http://yihui.name/knitr/) the file `insilicodb.Rmd`. You will need to have subdirectories called `cancer` and `celltype` in your working directory, and they should contain the Cuffdiff 2.2.1 output (LINK COMING). You may also need to install some R packages:

```r
install.packages('devtools')
install.packages('reshape2')
source('http://bioconductor.org/biocLite.R')
biocLite('ballgown')
biocLite('EBSeq')
```

You can also view my knitted report [here](http://htmlpreview.github.io/?https://github.com/alyssafrazee/ballgown_code/blob/master/InSilicoDB/insilicodb.html).

