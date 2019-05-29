# sRNA_snakemake_workflow

Trims, filters, clusters, and aligns small RNA samples

### Dependencies

This workflow requires samtools version 1.9, bowtie --version 1.2.2

### Setup requirements

Requires snakemake. Directories should be set up as follows BEFORE running snakemake:

main_file
├──Snakefile
├──config.yaml
├──data
│  ├──1_raw
│     ├──samples.fastq.gz (can be multiple)
├──genomes
│  ├──rfam
│     ├──rfam_reference_genome.fasta
│     ├──rfam_reference_genome.ebwt (can be multiple)
│  ├──chloroplast_mitochondrion
│     ├──chloroplast_mitochondrion_genome.fasta
│     ├──chloroplast_mitochondrion_genome.ebwt (can be multiple)


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

##### min_length

Defaulted to 19. Reads shorter than this int will be discarded.

##### max_length

Defaulted to 26. Read longer than this int will be discarded.

##### adapter_seq

Defaulted to Illumina adapter sequence. Specifies the adapter sequence. If left blank, workflow will attempt to auto-detect the adapter sequence and proceed to trim it via trimgalore

##### quality

Defaulted to 30. Reads with quality lower than this score will be discarded


#### filter_rfam

##### genome

Given correct directory structure, this should ALWAYS be formated as ./data/genomes/rfam/rfam_reference_genome


#### filter_c_m

##### genome

Given correct directory structure, this should ALWAYS be formated as ./data/genomes/chloroplast_mitochondrion/chloroplast_mitochondrion_genome


