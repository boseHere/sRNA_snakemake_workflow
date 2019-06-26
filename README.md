# sRNA_snakemake_workflow

Trims, filters, clusters, and aligns small RNA samples

Table of Contents
=================
* [Installing Snakemake] (#install)
* [Dependencies](#dependencies)    
* [File Setup](#file-setup)    
* [config\.yaml Requirements](#config-yaml-requirements)    
  -[Samples](#samples)    
  -[Genomes](#genomes)    
  -[Trim](#trim)    
  -[Filter_rfam](#filter_rfam)    
  -[Filter_c_m](#filter_c_m)    
  -[Cluster](#cluster)    


### Installing Snakemake

Snakemake documentation for installation can be found [here](https://snakemake.readthedocs.io/en/stable/getting_started/installation.html)    

### Dependencies

* Trimgalore v.0.6.2    
* cutadapt v.2.3    
* fastqc v.0.11.7    
* samtools v.1.9    
* bowtie v.1.2.2    
* ShortStack v.3.8.5    
* RNAfold v.2.3.2    
* XZ Utils 4.999.9 beta    
* liblzma 4.999.9 beta    


### File Setup

|-data    
│      |---1_raw    
│       |---|---samples.fastq.gz    
│       |---genomes    
│      |---|--chloroplast_mitocondrion_bowtie-index    
│      |---|---|---genome fasta + index files    
│      |---|--rfam_athaliana    
│      |---|---|---genome fasta + index files    
│      |---|---ro18_v2_fixed_ids_shortstack-index    
│      |---|---|---genome fasta + index files    
│-scripts    
│      |---match_qual_v2.py    
│-Snakefile     
│-config.yaml    





### config\.yaml Requirements

#### Samples

Give names of samples without file extensions (should be in fastq.gz). 

*Example*

samples:    
       - sample1    
       - sample2    
       - sample3    
    
* Note: Don't use tab to do the indent (yaml doesn't like it). Use 4 spaces instead.


#### Genomes


#### Paths

Give absolute paths to the trim_galore, bowtie, ShortStack, and samtools software. These can be obtaned via "$ which trim_galore"

#### Trim


* ##### min_length

   Defaulted to 19. Reads shorter than this int will be discarded.

* ##### max_length

   Defaulted to 26. Read longer than this int will be discarded.

* ##### adapter_seq

   Defaulted to Illumina adapter sequence. Specifies the adapter sequence. If left blank, workflow will attempt to auto-detect the adapter sequence and proceed to trim it via trimgalore

* ##### quality

   Defaulted to 30. Reads with quality lower than this score will be discarded



#### Filter_rfam

* ##### threads    
   Defaulted to 1, can be changed according to server capabilities
    
#### Filter_c_m

* ##### threads    
   Defaulted to 1, can be changed according to server capabilities

#### Cluster

* ##### bowtie_cores    
   Defaulted to 1, can be changed according to server capabilities
   
