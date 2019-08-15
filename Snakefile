# Author: Maya Bose
# Date: 5/31/19
# Run sRNA mapping workflow
# See README.md for usage instructions
# Author: Maya Bose


# Get configuration
configfile: "config.yaml"
SAMPLES = config["samples"]
#

# Run workflow
rule all:
    input:
        expand("data/8_fastqc_reports/{sample}_fastqc.zip", sample=SAMPLES)

# Index reference genomes
onstart:
    shell("scripts/index_genomes.sh")


# Trim reads
for ext in "fastq fq fastq.gz fq.gz".split():
    rule:
        input:
            expand("data/1_raw/{{sample}}.{ext}", ext=ext)
        output:
            "data/2_trimmed/{sample}_trimmed.fq.gz"
        params:
            min_length = config["trimming"]["min_length"],
            max_length = config["trimming"]["max_length"],
            adapter_seq = config["trimming"]["adapter_seq"],
            quality = config["trimming"]["quality"],
            path = config["paths"]["trim_galore"]
        shell:
            '''
            {params.path} \
            --adapter {params.adapter_seq} \
            --gzip \
            --length {params.min_length} \
            --max_length {params.max_length} \
            --output_dir data/2_trimmed/ \
            --quality {params.quality} \
            {input} 2>> output_logs/2_outlog.txt
            '''

# Filter out contaminating highly expressed RNAs
rule filter_rna:
    input:
        "data/2_trimmed/{sample}_trimmed.fq.gz"
    output:
        fqgz = "data/3_rfam_filtered/{sample}_rfam_filtered.fq.gz"
    threads:
        config["threads"]["filter_rna_bowtie"]
    params:
        fq = "data/3_rfam_filtered/{sample}_rfam_filtered.fq",
        rna_genome = config["genomes"]["filter_rna"],
        path = config["paths"]["bowtie"]
    run:
        if {params.rna_genome} == "./genomes/filter_rna/":
            shell("echo No contaminating RNA filter genome provided, \
            skipping this step")
        else:
            shell(
            '''
            {params.path} \
            -v 0 \
            -m 50 \
            --best \
            -a \
            --nomaqround \
            --norc \
            --threads {threads} \
            --un {params.fq} \
            {params.rna_genome} \
            {input} 1>> output_logs/3_outlog.txt \

            gzip {params.fq}
            ''')

# Filter out chloroplast and mitochondrial RNA
rule filter_c_m:
    input:
        name="data/2_trimmed/{sample}_trimmed.fq.gz" \
        if config["genomes"]["filter_rna"] == "./genomes/filter_rna/" else \
        "data/3_rfam_filtered/{sample}_rfam_filtered.fq.gz"
    output:
        fqgz = "data/4_c_m_filtered/{sample}_c_m_filtered.fq.gz"
    threads:
        config["threads"]["filter_c_m_bowtie"]
    params:
        fq = "data/4_c_m_filtered/{sample}_c_m_filtered.fq",
        c_m_genome = config["genomes"]["chloro_mitochondria"],
        path = config["paths"]["bowtie"]
    shell:
        '''
        {params.path} \
        -v 0 \
        -m 50 \
        --best \
        -a \
        --nomaqround \
        --threads {threads} \
        --un {params.fq} \
        {params.c_m_genome} \
        {input.name} 1>> output_logs/4_outlog.txt \

        gzip {params.fq}
        '''

# Cluster and align reads
rule cluster:
    input:
        expand("data/4_c_m_filtered/{sample}_c_m_filtered.fq.gz",
        sample=SAMPLES)
    output:
        "data/5_clustered/merged.bam"
    threads:
        config["threads"]["shortstack_cluster"]
    params:
        genome = config["genomes"]["reference_genome"],
        path = config["paths"]["ShortStack"],
        multi_map_handler = config["aligning"]["multi_map_handler"],
        sort_memory = config["aligning"]["sort_memory"]
    shell:
        '''
        rm -r data/5_clustered && \
        {params.path} \
        --sort_mem {params.sort_memory} \
        --mismatches 0 \
        --mmap {params.multi_map_handler} \
        --bowtie_cores {threads} \
        --nohp \
        --readfile {input} \
        --genomefile {params.genome}.fasta \
        --outdir data/5_clustered/ 1>> output_logs/5_outlog.txt && \
        mv data/5_clustered/*.bam data/5_clustered/merged.bam
        '''
# Split merged alignments file into multiple BAM files by sample name
rule split_by_sample:
    input:
        "data/5_clustered/merged.bam"
    output:
        expand("data/6_split_by_sample/{sample}_c_m_filtered.bam", sample=SAMPLES)
    params:
        path = config["paths"]["samtools"]
    shell:
        '''
        mkdir -p data/6_split_by_sample && \
        {params.path} \
        split \
        -f '%!.bam' \
        {input} 2>> output_logs/6_outlog.txt && \
        mv *.bam data/6_split_by_sample/
        '''

# Extract mapped reads into BAM files
rule convert_1:
    input:
        "data/6_split_by_sample/{sample}_c_m_filtered.bam"
    output:
        temp("data/temp_converted/int1/{sample}_int1.bam")
    threads:
        config["threads"]["mapped_reads_samtools"]
    params:
        path = config["paths"]["samtools"]
    shell:
        '''
        {params.path} \
        view \
        -F4 \
        -b \
        -@ {threads} \
        {input} > {output} 2>> Error.txt
        '''

# Convert BAM files to Fastq files
rule convert_2:
    input:
        "data/temp_converted/int1/{sample}_int1.bam"
    output:
        temp("data/temp_converted/{sample}_converted.fq")
    params:
        path = config["paths"]["samtools"]
    shell:
        '''
        {params.path} \
        bam2fq \
        -t {input} > {output} 2>> Error.txt
        '''

# Get encoding quality for Fastq files
rule retrieve_encoding_quality:
    input:
        "data/temp_converted/{sample}_converted.fq"
    output:
        "data/7_fastqs/{sample}.fastq"
    script:
        "scripts/match_qual_v2.py"


# Print length profiles of each sample to a log file
rule log_lengths:
    input:
        "data/7_fastqs/{sample}.fastq"
    output:
        "data/8_fastqc_reports/{sample}_fastqc.zip"
    threads:
        config["threads"]["fastqc_report"]
    shell:
        '''
        fastqc -o data/8_fastqc_reports -t {threads} {input} \
        2>> output_logs/7_outlog.txt && \
        scripts/fastq_readlength_profile.py {input} >> Final_Counts_Log.txt
        '''
