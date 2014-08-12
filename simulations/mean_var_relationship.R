## get mean/variance FPKM relationship from GEUVADIS dataset
## AF, updated 12 August 2014

source("http://bioconductor.org/biocLite.R")
biocLite('ballgown')
library(ballgown)
library(genefilter)

# load FPKM GEUVADIS object from figshare
system('wget http://files.figshare.com/1625419/fpkm.rda')
load('fpkm.rda')
#load(url('http://files.figshare.com/1625419/fpkm.rda')) # I am sad this does not work :'( :'(
sum(rowMeans(texpr(fpkm)) > 100)

texpr_nozero = texpr(fpkm)[rowMeans(texpr(fpkm)) > 100, ]
texpr_nozero[texpr_nozero==0] <- NA
means = rowMeans(texpr_nozero, na.rm=TRUE)

texpr_hi = texpr(fpkm)[rowMeans(texpr(fpkm)) > 100,]
plot(log(rowMeans(texpr_hi)), log(rowVars(texpr_hi)))
mvmod = lm(log(rowVars(texpr_hi)) ~ log(rowMeans(texpr_hi)))
abline(mvmod, lwd=4, col='dodgerblue')

summary(mvmod)
# lm(formula = log(rowVars(texpr_hi)) ~ log(rowMeans(texpr_hi)))

# Residuals:
#     Min      1Q  Median      3Q     Max 
# -3.0692 -1.2461 -0.6245  0.8662  7.9961 

# Coefficients:
#                         Estimate Std. Error t value Pr(>|t|)    
# (Intercept)              -5.5663     0.4099  -13.58   <2e-16 ***
# log(rowMeans(texpr_hi))   2.6698     0.0671   39.79   <2e-16 ***
# ---
# Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

# Residual standard error: 1.909 on 423 degrees of freedom
# Multiple R-squared:  0.7892,    Adjusted R-squared:  0.7887 
# F-statistic:  1583 on 1 and 423 DF,  p-value: < 2.2e-16


sessionInfo()
