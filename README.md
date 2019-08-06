# sRNA Snakemake Workflow

Runs an sRNA-seq data cleaning pipeline on a collection of fastq.gz files

Table of Contents
=================

* [Dependencies](#dependencies)    
* [Directory Structure](#directory-structure)    
* [config\.yaml Requirements](#config-yaml-requirements)    
  -[Samples](#samples)     
  -[Threads](#threads)     
  -[Genomes](#genomes)         
  -[Paths](#paths)     
  -[Trim](#trim)     


### Dependencies 
 
* Snakemake 
* Trimgalore v.0.6.2    
* cutadapt v.2.3    
* fastqc v.0.11.7    
* samtools v.1.9    
* bowtie v.1.2.2    
* ShortStack v.3.8.5    
* RNAfold v.2.3.2    
* XZ Utils 5.2.2    
* liblzma 5.2.2   


### Directory Structure

Ensure you have the following directory structure in place before running snakemake
```
 .
├── _data 
│   └── 1_raw
│       └── # YOUR FASTQ.GZ FILES CONTAINING SRNA-SEQ DATA HERE
├── _genomes 
│   └── _chloroplast_mitocondrion
│       └── # FASTA FILE CONTAINING THE ASSEMBLED CHLOROPLAST + MITOCHODRIAL GENOME FOR YOUR ORGANISM HERE
│   └── _filter_rna
│       └── # FASTA FILE CONTAINING THE ASSEMBLED NON-SRNA RNA GENOME FOR YOUR ORGANISM HERE
│   └── _refenrece_genome
│       └── # FASTA FILE CONTAINING THE ASSEMBLED GENOME FOR YOUR ORGANISM HERE
├── _output_logs 
├── _scripts 
│   └── index_genomes.sh
│   └── match_qual_v2.py
├── config.yaml
└── Snakefile
```
As snakemake runs, the data folder will become populated with folders numbered in the order they are created.

### config\.yaml Requirements

#### Samples

Give names of samples *without* file extensions.

*Example*
```
samples:    
       - sample_name1    
       - sample_name2    
       - sample_name3    
```
Sample names should be indented using 4 spaces (not the indent key), and be preceded by a dash character "-" and another space.


#### Genomes

Fill in the three absolute paths with the names of your genome files.     

The first two paths (for filter_rna & chloro_mitochondria)
require the BUILD NAME of the genome file. This is simply the name of the genome files without the .fasta extensions.     

The third path (for the reference_genome), requires the FILENAME of the genome file. This is the name of the genome file INCLUDING its
.fasta extension.

*Example*
```
genomes:
    filter_rna : ./genomes/filter_rna/my_rna_genome
    chloro_mitochondria : ./genomes/chloroplast_mitocondrion/my_cm_genome
    reference_genome : ./genomes/reference_genome/my_ref_genome.fasta
```


#### Paths

Give absolute paths to the trim_galore, bowtie, ShortStack, and samtools software if they are not already sym-linked to a 
location in /usr/local/bin/. To test if these software are sym-linked, you can run the following on the command line.
```
$ which trim_galore
$ which bowtie
$ which ShortStack
$ which Samtools
```
If these lines return a path, leave this section as it is upon downloading. 


#### Trim


* ##### min_length

   Defaulted to 19. Reads shorter than this int will be discarded.

* ##### max_length

   Defaulted to 26. Read longer than this int will be discarded.

* ##### adapter_seq

   Defaulted to Illumina adapter sequence. Specifies the adapter sequence. If left blank, workflow will attempt to auto-detect the adapter sequence and proceed to trim it via trimgalore

* ##### quality

   Defaulted to 30. Reads with quality lower than this score will be discarded
