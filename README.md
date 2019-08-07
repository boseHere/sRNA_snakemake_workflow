# sRNA Snakemake Workflow

Runs an sRNA-seq data cleaning pipeline on a collection of fastq.gz, fastq, fq, or fq.gz files

Table of Contents
=================

* [Dependencies](#dependencies)    
* [Directory Structure](#directory-structure)     
* [Editing Config](#editing-config)     
  -[Automatically Fill In Config](#automatically-fill-in-config)     
  -[Samples](#samples)     
  -[Threads](#threads)     
  -[Genomes](#genomes)         
  -[Paths](#paths)     
  -[Trimming](#trimming)    
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

### Directory Structure

Ensure you have the following directory structure in place before running snakemake from the top level directory.
```
 .
├── _data 
│   └── 1_raw
│       └── # YOUR FASTQ.GZ, FASTQ, FQ.GZ, AND FQ FILES CONTAINING SRNA-SEQ DATA HERE
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

### Editing Config

Editing the config.yaml file for this pipeline allows you to specify your files, reference genomes, software pathways, and trimming 
parameters. To edit the config file, run
```
$ nano config.yaml
```
then fill out the sections as described below. Save via `Ctrl-o`, then exit the config file via `Ctrl-x`.

#### Automatically Fill In Config

You have the option to either fill in all sections of the config.yaml file manually, or to allow the custom script build_config.sh to fill in the names of your samples and genomes according to what you have in your /data/1_raw and /genomes directories. 

This option was created because filling in the config.yaml with the names of your samples can be tedious, especially if you have a lot of samples or don't already have a list of all your samples/sample filenames without their extensions. Furthermore, mistakes may be made while filling in the names of your genomes in the "genomes" section of the config file, as the chloro_mitochondria and rna filter genomes have a different format for specifying the name of the genome file than the reference_genome does, due to the pipeline using 2 different alligment tools. These differences are noted in the config.yaml template that comes with the download of this pipeline, so feel free to fill it out manually if you prefer. 
     
Otherwise, to have the config.yaml file automatically filled in with the names of your samples/genomes, simply run
```
$ ./scripts/build_config.sh
```
before running
```
$ nano config.yaml
```
to proceed with filling in the [Trimming](#trimming), [Threads](#threads), and [Paths](#paths) sections of the config file. 
    
#### Trimming

Set the minimum and maximum read length you are interested in. The advised defaults for sRNA are a minimum length of 19 and a maximum 
length of 26. 
Set the adaptor sequence used when creating the sRNA seq libraries. Some commonly used adapters:    
  * Illumina Adapter: AGATCGGAAGAGC    
  * Illumina sRNA Adapter: TGGAATTCTCGG    
  * Nextera Adapter: CTGTCTCTTATA    
    
This pipeline will not work on sequences that have already been adapter-trimmed.     
    
Set the minimum read quality cut-off. Default is 30. 
    
#### Threads

Set the number of threads for each program to run with. The advised default is 10 for all programs, but this number can be scaled down
given server limitations. It is advised not to go above 10 threads for each program, as this decreases the number of processes snakemake
can run in parallel. 
    
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
    
#### Samples

Give names of the sample files located in your /data/1_raw directory *without* file extensions.

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
        
### __Running Snakemake__

The pipeline should be run only after you have populated your data/1_raw/ file with your sample files and placed the appropriate .fasta genome files into /genomes/chloro_mitocondrion/, genomes/filter_rna/, and genomes/reference_genome/. See [Directory Structure](#directory-structure) for a concise glance at what your directory structure should look like from the top level before running the pipeline.

The pipeline also requires that the config.yaml file be filled out before running. See [Editing Config](#editing-config) for more information on how to do that. The config.yaml file itself also contains comments to assist with filling it in.

To run the pipeline, execute the following on the command line from the top level of the directory structure:
```
$ snakemake --cores # INSERT MAX NUMBER OF CORES HERE
```
If a previous snakemake process was interrupted, you may need to run the following to unlock the directory before running the snakemake
the pipeline again:
```
$ snakemake --unlock
```
