# get geuvadis population data from ENA + HapMap websites

#### download ENA accesson numbers 
import urllib2
ena_info = urllib2.urlopen("http://www.ebi.ac.uk/ena/data/warehouse/filereport?accession=ERP001942&result=read_run&fields=study_accession,secondary_study_accession,sample_accession,secondary_sample_accession,experiment_accession,run_accession,scientific_name,instrument_model,library_layout,fastq_ftp,fastq_galaxy,submitted_ftp,submitted_galaxy,col_tax_id,col_scientific_name")
#ena_info = urllib2.urlopen("http://www.ebi.ac.uk/ena/data/warehouse/search?query=%22secondary_study_accession=%22ERP001942%22%22&result=read_run&limit=667&length=667&offset=0&display=report&fields=study_accession,secondary_study_accession,sample_accession_list,experiment_accession,run_accession,scientific_name,instrument_model,library_layout,fastq_ftp,fastq_galaxy,submitted_ftp,submitted_galaxy,col_taxonomy") ### OUTDATED as of 2/8/14
dat = ena_info.readlines()
table_rows = [x.split('\t') for x in dat][1:] #strip off header row
col_labels = dat[0].split('\t')
ftpind = col_labels.index('submitted_ftp') #11
sample_ftps = [x[ftpind] for x in table_rows]
len(set(sample_ftps)) #667
numinfront = len("ftp.sra.ebi.ac.uk/vol1/ERA169/ERA169774/fastq/")
hapmapids = [x[numinfront:][:7] for x in sample_ftps]
len(set(hapmapids)) #464 unique hapmap samples 

## note: from paper supplement:
## 5 samples sequenced in replicate at each of 7 labs (so 8x total)
## 168 samples sequenced in replicate at 2/3 coverage
## sooo, we have 465 base samples + 35 + 168 replicates = 668
## one sample is missing from ENA.

### population information
sample_info = urllib2.urlopen("ftp://ftp-trace.ncbi.nih.gov/1000genomes/ftp/sequence.index")
popdat = sample_info.readlines()
pdrows = [x.split('\t') for x in popdat]
idcol = pdrows[0].index('SAMPLE_NAME')
popcol = pdrows[0].index('POPULATION')
lookup = dict()
for entry in pdrows[1:]:
    lookup[entry[idcol]] = entry[popcol]

### sex information
# import pandas #ugh HapMap uses excel
# # had to pip install xlrd
# hapmap_pheno = pandas.ExcelFile('/Users/alyssafrazee/Google Drive/hopkins/research/_ballgown/ballgown_code/GEUVADIS_preprocessing/HapMap_samples.xls')
# hapmap_dat = hapmap_pheno.parse('4_pops')
# enc = hapmap_pheno.parse('ENCODE')
# this isn't enough data! :'( 

hapmap_info = urllib2.urlopen("ftp://ftp-trace.ncbi.nih.gov/1000genomes/ftp/technical/working/20130606_sample_info/20130606_sample_info.txt")
hapmap_lines = hapmap_info.readlines()
hapmap_rows = [x.split('\t') for x in hapmap_lines]
idcol = hapmap_rows[0].index('Sample')
sexcol = hapmap_rows[0].index('Gender')
sexlookup = dict()
for entry in hapmap_rows[1:]:
    sexlookup[entry[idcol]] = entry[sexcol]

out_table = 'pop_data_withuniqueid.txt'
errind = col_labels.index('run_accession')

# add identifiers to this table (to look up in the table from the geuvadis authors, QCstats)
ids = [x.split(';')[0].split('/')[-1][:-11] for x in sample_ftps]
with open(out_table, 'w') as f:
    f.write('sample_id\trun_id\thapmap_id\tpopulation\tsex\n')
    pos = 0
    for h in hapmapids:
        f.write(ids[pos]+'\t'+table_rows[pos][errind]+'\t'+h+'\t'+lookup[h]+'\t'+sexlookup[h]+'\n')
        pos += 1








