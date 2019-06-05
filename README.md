# sRNA_snakemake_workflow

Trims, filters, clusters, and aligns small RNA samples

Table of Contents
=================
* [Dependencies](#dependencies)
* [File Setup](#file_setup)


### Dependencies

This workflow requires trim_galore version 0.6.2, samtools version 1.9, bowtie version 1.2.2, ShortStack version 3.8.5


### File Setup

|-data    
│    |---1_raw    
│    |---|---samples.fastq.gz    
│    |---genomes    
│    |---|--chloroplast_mitocondrion_bowtie-index    
│    |---|---|---genome fasta + index files    
│    |---|--rfam_athaliana    
│    |---|---|---genome fasta + index files    
│    |---|---ro18_v2_fixed_ids_shortstack-index    
│    |---|---|---genome fasta + index files    
│-scripts    
│    |---match_qual_v2.py    
│-Snakefile     
│-config.yaml    

### config.yaml requirements

#### samples

Give names of samples without file extensions (should be in fastq.gz). 

Example

samples:
    -sample1
    -sample2
    -sample3
    
* Note: Don't use tab to do the indent (yaml doesn't like it). Use 4 spaces instead.



#### trim

* ##### min_length

   Defaulted to 19. Reads shorter than this int will be discarded.

* ##### max_length

   Defaulted to 26. Read longer than this int will be discarded.

* ##### adapter_seq

   Defaulted to Illumina adapter sequence. Specifies the adapter sequence. If left blank, workflow will attempt to auto-detect the adapter sequence and proceed to trim it via trimgalore

* ##### quality

   Defaulted to 30. Reads with quality lower than this score will be discarded



#### filter_rfam

* ##### genome

   Given correct directory structure, this should ALWAYS be formated as ./data/genomes/rfam/rfam_reference_genome



#### filter_c_m

* ##### genome

   Given correct directory structure, this should ALWAYS be formated as ./data/genomes/chloroplast_mitochondrion/chloroplast_mitochondrion_genome


