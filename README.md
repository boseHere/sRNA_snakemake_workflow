# sRNA Snakemake Workflow

Runs an sRNA-seq data cleaning pipeline on a collection of fastq.gz files

Table of Contents
=================

* [Dependencies](#dependencies)    
* [Directory Structure](#directory-structure)     
* [Configuring config.yaml](#configuring-config.yaml)     
  -[Samples](#samples)     
  -[Threads](#threads)     
  -[Genomes](#genomes)         
  -[Paths](#paths)     
  -[Trim](#trim)     
* [Running Snakemake](#running-snakemake)


### __Dependencies__ 
 
* Snakemake  5.4.5
* Trimgalore 0.6.2    
* cutadapt 2.3    
* fastqc 0.11.7    
* samtools 1.9    
* bowtie 1.2.2    
* ShortStack 3.8.5    
* RNAfold 2.3.2    
* XZ Utils 5.2.2    
* liblzma 5.2.2   

*Coming soon!* A singularity container with all dependent software to run this pipeline. Once the container is published, running this
pipeline will be as simple as installing singularity, pulling the .sif image, and running:
```
$ singularity exec mosher_lab_srna.sif snakemake --cores 10
```

### __Directory Structure__

Ensure you have the following directory structure in place before running snakemake from the top level directory.
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

### Configuring config.yaml

Editing the config.yaml file for this pipeline allows you to specify your files, reference genomes, software pathways, and trimming 
parameters. 

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
    
#### Threads

Set the number of threads for each program to run with. The advised default is 10 for all programs, but this number can be scaled down
given server limitations. It is advised not to go above 10 threads for each program, as this decreases the number of processes snakemake
can run in parallel. 
    
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
If these lines return a path, leave this section as is upon downloading. 


#### Trim

Set the minimum and maximum read length you are interested in. The advised defaults for sRNA are a minimum length of 19 and a maximum 
length of 26. 
Set the adaptor sequence used when creating the sRNA seq libraries. Some commonly used adapters:    
  * Illumina Adapter: AGATCGGAAGAGC    
  * Illumina sRNA Adapter: TGGAATTCTCGG    
  * Nextera Adapter: CTGTCTCTTATA    
    
This pipeline will not work on sequences that have already been adapter-trimmed.     
    
Set the minimum read quality cut-off. Default is 30. 
     
### __Running Snakemake__

To run the pipeline, execute the following on the command line from the top level of the [directory structure](#directory-structure):
```
$ snakemake --cores # INSERT MAX NUMBER OF CORES HERE
```
If a previous snakemake process was interrupted, you may need to run the following to unlock the directory before running the snakemake
the pipeline again:
```
$ snakemake --unlock
```
