## code for InSilico DB analysis in ballgown manuscript

This code executes the analysis of two datasets from [InSilico DB](https://insilicodb.com/) presented in the [ballgown manuscript](http://biorxiv.org/content/early/2014/09/05/003665). Specifically, this code produces Supplementary Figure 5, results in Supplementary Note 4, and results in the main manuscript paragraph beginning "Next, we carried out experiments designed to represent realistic differential expression scenarios..."

### dependencies

#### data from InSilico DB

Cuffdiff 2.0.2 results were downloaded from [InSilico DB](https://insilicodb.com/) on March 5, 2014. In case this data changes, we have uploaded freezes of the data we used:
* Accession number GSE36552, [developmental cell type dataset](https://www.dropbox.com/s/b4d44s7vtpzb4im/GSE36552GPL11154_DGE_RNASeq_04ec2b6a46a9ddb8ef2083b9d8ba4e3c.tgz)
* Accession number GSE37764, [adenocarcinoma dataset](https://www.dropbox.com/s/ql7kb94fx7c5e44/GSE37764GPL10999_DGE_RNASeq_a9dc2c94672e4a51c036c76be9508164.tgz)

To use this code, you'll need these freezes. Untar/unzip them to get the database files used.

To download these datasets:  
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
* The sqldf, reshape2, and devtools packages from CRAN:
```S
install.packages('sqldf')
install.packages('reshape2')
install.packages('devtools')
```
* the ballgown, cummeRbund, and EBSeq R packages from Bioconductor:
```R
source("http://bioconductor.org/biocLite.R")
biocLite('ballgown')
biocLite('cummeRbund')
biocLite('EBSeq')
```
* my "usefulstuff" package from GitHub (for the transparent double histograms)
```R
library(devtools)
install_github('alyssafrazee/usefulstuff')
```

### scripts
After getting the data and installing the required R libraries, run the script `insilicodb.R` to make Supplementary Figures 7b and 7d. As long as you put the downloaded data into your working directory, you don't need to change any paths in this script. To make Supplementary Figures 7a and 7c, [knit](http://yihui.name/knitr/) the file `insilicodb.Rmd`. You will need to have subdirectories called `cancer` and `celltype` in your working directory, and they should contain the Cuffdiff 2.2.1 output. You can get those directories by cloning this repo and unzipping `cancer.zip` and `celltype.zip` (both in this subfolder).

### Cuffdiff scripts

The data from InSilicoDb was analyzed with Cuffdiff 2.0.2 (Suppelementary Figures 7b, 7d). We also analyzed this data with Cuffdiff 2.2.1 (Supplementary Figures 7a, 7c). That required going all the way back to the raw fastq files, which we downloaded from the [Sequence Read Archive](http://www.ncbi.nlm.nih.gov/sra), and processing them through the full RNA-seq pipeline. We did that using the code in `run_pipeline.sh`, located in `cancer_output` and `celltype_output` (for each experiment). But you really only need the unzipped cancer/celltype Cuffdiff output to create the figures.

Some notes on the preprocessing (`run_pipeline`) scripts:

* It requires TopHat 2.0.11, Cufflinks 2.2.1, Python 2.7, and the [SRA toolkit](http://www.ncbi.nlm.nih.gov/Traces/sra/?view=software)
* I used our cluster's SGE scheduling system to run jobs in parallel
* It uses an [annotation index](http://ccb.jhu.edu/software/tophat/igenomes.shtml) and a [pre-built TopHat transcriptome index](https://github.com/alyssafrazee/ballgown_code/tree/master/simulations/tophat_transcriptome) (hg19) where the "Homo_sapiens" folder is assumed to be here in the working directory. 
* I manually curated `metadata.txt` based on the annotations in SRA and InSilico DB, and I downloaded `SraRunInfo.csv` from SRA [here](http://www.ncbi.nlm.nih.gov/sra?term=SRP012656) for cancer and [here](http://www.ncbi.nlm.nih.gov/sra?term=SRP012656) for celltype. Directions in the `get_fastq.py` file comments.
* Run the script by just doing `sh run_pipeline.sh`. It will take a really long time (several hours, and possibly days with Cuffdiff on this many replicates). 

You can view my final knitted report [here](http://htmlpreview.github.io/?https://github.com/alyssafrazee/ballgown_code/blob/master/InSilicoDB/insilicodb.html).

