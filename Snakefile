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
		expand("data/9_fastqc_reports/{sample}_fastqc.zip", sample=SAMPLES)

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
			"{params.path} "
			"--adapter {params.adapter_seq} "
			"--gzip "
			"--length {params.min_length} "
			"--max_length {params.max_length} "
	                	"--output_dir data/2_trimmed/ "
			"--quality {params.quality} "
			"{input} >> output_logs/2_outlog.txt"

# Filter out junk RNA
rule filter_rfam:
	input:
		"data/2_trimmed/{sample}_trimmed.fq.gz"
	output:
		"data/3_rfam_filtered/{sample}_rfam_filtered.fq"
	threads:
		config["threads"]["filter_rna_bowtie"]
	params:
		rna_genome = config["genomes"]["filter_rna"],
		path = config["paths"]["bowtie"]
	shell:
			"{params.path} "
			"-v 0 "
			"-m 50 "
			"--best "
			"-a "
			"--nomaqround "
			"--norc "
			"--threads {threads} "
			"--un {output} "
			"{params.rna_genome} "
			"{input} >> output_logs/3_outlog.txt"
				


# Filter out chloroplast and mitochondrial RNA
rule filter_c_m:
	input:
		"data/3_rfam_filtered/{sample}_rfam_filtered.fq"
	output:
		"data/4_c_m_filtered/{sample}_c_m_filtered.fq"
	threads:
		config["threads"]["filter_c_m_bowtie"]
	params:
		c_m_genome = config["genomes"]["chloro_mitochondria"],
		path = config["paths"]["bowtie"]
	shell:
		"{params.path} "
		"-v 0 "
		"-m 50 "
		"--best "
		"-a "
		"--nomaqround "
		"--threads {threads} "
		"--un {output} "
		"{params.c_m_genome} "
		"{input} >> output_logs/4_outlog.txt"
	

# Cluster and align reads
rule cluster:
	input:
		expand("data/4_c_m_filtered/{sample}_c_m_filtered.fq", sample=SAMPLES)
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
		"rm -r data/5_clustered && " 
		"{params.path} "
		"--sort_mem {params.sort_memory} "
		"--mismatches 0 "
		"--mmap {params.multi_map_handler} "
		"--bowtie_cores {threads} "
		"--nohp "
		"--readfile {input} "
		"--genomefile {params.genome}.fasta "
		"--outdir data/5_clustered/ output_logs/5_outlog.txt && "
		"mv data/5_clustered/*.bam data/5_clustered/merged.bam "

# Split merged alignments file into multiple BAM files by sample name
rule split_by_sample:
	input:
		"data/5_clustered/merged.bam"
	output:
		expand("data/6_split_by_sample/{sample}_c_m_filtered.bam",sample=SAMPLES)
	params:
		path = config["paths"]["samtools"]
	shell:
		"mkdir -p data/6_split_by_sample && "
		"{params.path} " 
		"split "
  		"-f '%!.bam' "
		"{input} >> output_logs/6_outlog.txt && "
		"mv *.bam data/6_split_by_sample/ "


# Extract mapped reads into BAM files
rule convert_1:
	input:
		"data/6_split_by_sample/{sample}_c_m_filtered.bam"
	output:
		"data/7_converted/int1/{sample}_int1.bam"
	threads:
		config["threads"]["mapped_reads_samtools"]
	params:
		path = config["paths"]["samtools"]
	shell:
		"{params.path} "
		"view "
		"-F4 "
		"-b "
		"-@ {threads} "
		"{input} > {output} >> Error.txt"


# Convert BAM files to Fastq files
rule convert_2:
	input:
		"data/7_converted/int1/{sample}_int1.bam"
	output:
		"data/7_converted/{sample}_converted.fq"
	params:
		path = config["paths"]["samtools"]
	shell:
		"{params.path} "
		"bam2fq "
		"-t {input} > {output} 2>> Error.txt"


# Get encoding quality for Fastq files
rule retrieve_encoding_quality:
	input:
		"data/7_converted/{sample}_converted.fq"
	output:
		"data/8_fastqs/{sample}.fastq"
	script:
		"scripts/match_qual_v2.py"

# Print length profiles of each sample to a log file
rule log_lengths:
	input:
		"data/8_fastqs/{sample}.fastq"
	output:
		"data/9_fastqc_reports/{sample}_fastqc.zip"
	threads:
		1
	shell:
		"fastqc -o data/9_fastqc_reports -t 1 {input} " 
		"1>> output_logs/7_outlog.txt 2>> Error.txt && "
		"scripts/fastq_readlength_profile.py {input} >> Counts_Log.txt"

onsuccess:
	shell("rm -r data/7_converted")
	shell("mv data/9_fastqc_reports/ data/8_fastqc_reports/")
	shell("mv data/8_fastqs/ data/7_fastqs")
	shell("gzip data/3_rfam_filtered/*.fq")
	shell("gzip data/4_c_m_filtered/*.fq")
