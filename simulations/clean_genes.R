# remove all chromosomes except 1-22, X, Y from gtf file

tx = read.table("genes.gtf",sep="\t")
tx.clean = subset(tx,V1==1|V1==2|V1==3|V1==4|V1==5|V1==6|V1==7|V1==8|V1==9|V1==10|V1==11|V1==12|V1==13|V1==14|V1==15|V1==16|
  V1==17|V1==18|V1==19|V1==20|V1==21|V1==22|V1=="X"|V1=="Y")
write.table(tx.clean, file="genes-clean.gtf", col.names=FALSE, row.names=FALSE, quote=FALSE)
