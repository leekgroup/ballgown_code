## code for InSilico DB analysis in ballgown manuscript

This code executes the analysis of two datasets from [InSilico DB](https://insilicodb.com/) presented in the [ballgown manuscript](http://biorxiv.org/content/early/2014/03/30/003665). Specifically, this code produces Figure 2a and 2b.

### dependencies

#### data from InSilico DB

We downloaded our data from InSilico DB on March 5, 2014. In case this data changes, we have uploaded freezes of the data we used [here](). 

Accession numbers are:
* GSE36552 for the developmental cell type dataset
* GSE37764 for the adenocarcinoma dataset

To get these datasets:  
  1. Go to insilicodb.com  
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
* The ballgown R package from GitHub:
```S
install.packages('devtools') #if needed
library(devtools)
install_github('ballgown', 'alyssafrazee')
```

### script
After getting the data and installing the required R libraries, run the script `insilicodb.R`. As long as you put the downloaded data into your working directory, you don't need to change any paths in this script.

