# sRNA Snakemake Workflow

Runs an sRNA-seq data analysis pipeline on a collection of fastq.gz, fastq, fq, or fq.gz files.

Table of Contents
=================

* [Dependencies](#dependencies)
* [How to Run the Pipeline](#how-to-run-the-pipeline)
  - [Directory Structure](#directory-structure)
  - [Editing Config](#editing-config)
    * [Automatically Fill In Config](#automatically-fill-in-config)
    * [Trimming](#trimming)
    * [Aligning](#aligning)
    * [Threads](#threads)
    * [Paths](#paths)
    * [Samples](#samples)
    * [Genomes](#genomes)
* [About the Output Files](#about-the-output-files)
* [Flowchart of Pipeline Functions](#flowchart-of-pipeline-functions)
* [References](#references)


### Dependencies

Snakemake 5.4.5, Trimgalore 0.6.2, cutadapt 2.3. fastqc 0.11.7, samtools 1.9, bowtie 1.2.2, ShortStack 3.8.5, RNAfold 2.3.2, XZ Utils 5.2.2, liblzma 5.2.2

*Coming soon!* A singularity container with all dependent software to run this pipeline. Once the container is published, running this
pipeline will be as simple as installing singularity, pulling the .sif image, and running:
```
$ singularity exec mosher_lab_srna.sif snakemake --cores 10
```

### How to Run the Pipeline

1. Ensure that the [Dependencies](#dependencies) for the pipeline have been installed.

2. Clone this repository into your current directory from the command line by running:

```shell
$ git clone https://github.com/boseHere/sRNA_snakemake_workflow
$ cd sRNA_snakemake_workflow
```

3. Add your sample files to the `data/1_raw/` directory. These can be fastq, fq, fastq.gz, or fq.gz files. See [Samples](#samples) for more info about this.
4. Add your genomes files (chloroplast and mitochondria genome, reference genome, and optional non-coding RNA genome) to the corresponding subdirectories in the `genomes` directory. See [Genomes](#genomes) for more info about this.
5. Check that your directory structure within the `sRNA_snakemake_workflow` folder matches that described. See [Directory Structure](#directory-structure) for a concise glance at what your directory structure should look like from the top level before running the pipeline.
6. Fill out the config.yaml file in the top level directory. See [Editing Config](#editing-config) for more information on the different sections of the file and how to fill them out. The config.yaml file that is downloaded with this repository also contains comments to assist with filling it in.
7. Execute the following on the command line from the top level of the directory structure:

```shell
$ snakemake --cores # INSERT MAX NUMBER OF CORES HERE
```

If a previous snakemake process was interrupted, you may need to run the following to unlock the directory before running the snakemake
the pipeline again:

```shell
$ snakemake --unlock
```

#### Directory Structure

Ensure you have the following directory structure in place before running snakemake from the top level directory. This structure should be already in place if you download this repository with `git clone`, and should only require that you fill in your sample and genome files.

```
.
├── _data
│   └── 1_raw
│       └── # YOUR FASTQ.GZ, FASTQ, FQ.GZ, AND FQ FILES CONTAINING SRNA-SEQ DATA HERE
├── _genomes
│   └── _chloro_mitochondria
│       └── # MULTI-FASTA FILE CONTAINING CHLOROPLAST AND/OR MITOCHODRIAL GENOME(S) FOR YOUR ORGANISM HERE
│   └── _filter_rna
│       └── # MULTI-FASTA FILE CONTAINING NON-CODING RNA SEQUENCES TO BE FILTERED OUT OF INPUT READS HERE (OPTIONAL)
│   └── _reference_genome
│       └── # MULTI-FASTA FILE CONTAINING THE GENOME FOR YOUR ORGANISM HERE
├── _output_logs
├── _scripts
│   └── build_config.sh
│   └── fastq_readlength_profile.py
│   └── index_genomes.sh
│   └── match_qual_v2.py
├── config.yaml
└── Snakefile
```

As snakemake runs, the data folder will become populated with folders numbered in the order they are created.

#### Editing Config

Editing the config.yaml file for this pipeline allows you to specify your files, reference genomes, software pathways, and trimming
parameters. To edit the config file, run

```shell
$ nano config.yaml
```

then fill out the sections as described below. Save via `Ctrl-o`, then exit the config file via `Ctrl-x`.

##### Automatically Fill In Config

You have the option to either fill in all sections of the config.yaml file manually, or to allow the custom script build_config.sh to fill in the names of your samples and genomes according to what you have in your /data/1_raw and /genomes directories.

This option was created because filling in the config.yaml with the names of your samples and genomes can be tedious, especially if you have a lot of samples or don't already have a list of all your sample filenames without their extensions. Further specifications on filling out the config file are noted in the config.yaml template that comes with the download of this pipeline, so feel free to fill it out manually if you prefer.

Otherwise, to have the config.yaml file automatically filled in with the names of your samples/genomes, from the top level of the directory structure, simply run

```shell
$ ./scripts/build_config.sh
```

before running

```shell
$ nano config.yaml
```

to proceed with filling in the [Trimming](#trimming), [Aligning](#aligning), [Threads](#threads), and [Paths](#paths) sections of the config file.

##### Trimming

Set the minimum and maximum read length you are interested in. The advised defaults for sRNA are a minimum length of 19 and a maximum
length of 26.

Set the adaptor sequence used when creating the libraries. Some commonly used adapters:
  * Illumina Adapter: AGATCGGAAGAGC
  * Illumina sRNA Adapter: TGGAATTCTCGG
  * Nextera Adapter: CTGTCTCTTATA

This pipeline (currently) will **not** work on sequences that have already been adapter-trimmed.

Set the minimum read quality cut-off. Default is 30.

##### Aligning

Fill in the desired protocol to handle multi-mapping reads during the alignment process. The options for this, as described by the [ShortStack documentation](https://github.com/MikeAxtell/ShortStack) include n (none), r (random), u (unique- seeded guide), or f (fractional-seeded guide). The suggested default is u.

Also fill in the desired amount of memory to be allocated for sorting bam files. The default for this is 20G, though you may want to increase this if you find the pipeline crashing during the clustering step, or if you have many large sample files.

##### Threads

Set the number of threads for each program to run with. The advised default is 10 for all programs, but this number can be scaled down
given server limitations. It is advised not to go above 10 threads for each program, as this decreases the number of processes snakemake
can run in parallel.

##### Paths

Give absolute paths to the trim_galore, bowtie, ShortStack, and samtools software if they are not already sym-linked to a
location in /usr/local/bin/. To test if these software are sym-linked, you can run the following on the command line.

```shell
$ which trim_galore
$ which bowtie
$ which ShortStack
$ which Samtools
```

If these lines return a path, leave this section as is upon downloading.

##### Samples

Give names of the sample files located in your /data/1_raw directory *without* file extensions.

*Example*

```yaml
samples:
       - sample_name1
       - sample_name2
       - sample_name3
```

Sample names should be indented using 4 spaces (not the indent key), and be preceded by a dash character "-" and another space.

##### Genomes

Fill in the three absolute paths with the names of your genome files.

The noncoding RNA filtering step of this pipeline is recommended for sRNA alignment, but not required for the pipeline to run. This step removes contaminating commonly highly expressed RNAs from your sequences. The .fasta file, containing these contaminating sequences, used to perform this filtering step should be placed in `/genomes/filter_rna/`. However, if you choose to not use this step, then no file is required in this directory. The genome file for this step can be obtained from [Ensembl](http://ensemblgenomes.org/) or [Rfam](https://rfam.xfam.org/). **MAKE SURE** that the file you use for this filtering step is stripped of microRNAs and preRNAs before running the pipeline; these should be included in the alignment process.

The three file paths require the BASE NAME of the genome file. This is simply the name of the genome files without the .fasta extensions. If you choose not to use the additional filtering step to remove additional contaminating RNAs, simply leave the file path as is (blank).

*Example (using the additional filtering step)*

```yaml
genomes:
    filter_rna : ./genomes/filter_rna/my_rna_genome
    chloro_mitochondria : ./genomes/chloroplast_mitocondrion/my_cm_genome
    reference_genome : ./genomes/reference_genome/my_ref_genome
```

*Example (NOT using the additional filtering step)*

```yaml
genomes:
    filter_rna : ./genomes/filter_rna/
    chloro_mitochondria : ./genomes/chloroplast_mitocondrion/my_cm_genome
    reference_genome : ./genomes/reference_genome/my_ref_genome
```

### About the Output Files

Once the pipeline has completed running, you will see 7 additional sub-directories appear in the /data/ directory alongside the 1_raw directory. These should include:
* /2_trimmed/: This folder contains 1 fastq.gz file for each sample provided as input to the pipeline. The files in this folder have been selected for size and quality according to the specification given in the [Trimming](#trimming) section of the config file.
* /3_ncrna_filtered/: This folder will only appear if the additional filtering step, as described in [Genomes](#genomes) was used. This folder will contain 1 fq.gz file for each sample provided as input to the pipeline. These files have had all contaminating non-coding RNAs filtered out.
* /4_c_m_filtered/: This folder contains 1 fq.gz file for each sample provided as input to the pipeline. These files have had all chloroplast and/or mitochondrial reads filtered out.
* /5_clustered/: This folder contains the output of aligning all sample files to the given reference genome using [ShortStack](https://github.com/MikeAxtell/ShortStack)
* /6_split_by_sample/: This folder contains 1 bam file for each sample provided as input to the pipeline. This file contains the alignment information for each sample.
* /7_fastqs/: This folder contains 1 fastq file for each sample provided as input to the pipeline. These files contain the reads that aligned to the reference genome.

### Flowchart of Pipeline Functions

This flowchart demonstrates the steps of the pipeline, including what tools are used, what files are created, and where they are stored.

![Flowchart](dag.png)

### References

Johnson NR, Yeoh JM, Coruh C, Axtell MJ. (2016). G3 6:2103-2111.
    doi:10.1534/g3.116.030452

Grover JW, Kendall T, Baten A, Burgess D, Freeling M, King GJ, and Mosher RA.
    Maternal components of RNA ‐ directed DNA methylation are required for seed development in Brassica rapa.
    The Plant Journal. 2018. doi:10.1111/tpj.13910
