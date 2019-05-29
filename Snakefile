# Author: Maya Bose
# Date:
# Run sRNA mapping workflow


# Get configuration
configfile: "config.yaml"
SAMPLES = config["samples"]
#

# Run workflow
rule all:
	input:
		expand("data/4_c_m_filtered/{sample}_c_m_filtered.fq", sample=SAMPLES)

# Trim reads
rule trim:
	input:
		expand("data/1_raw/{sample}.fastq.gz", sample=SAMPLES)
	output:
		expand("data/2_trimmed/{sample}_trimmed.fq.gz", sample=SAMPLES)
	params:
		min_length = config["trim"]["min_length"],
		max_length = config["trim"]["max_length"],
		adapter_seq = config["trim"]["adapter_seq"],
		quality = config["trim"]["quality"],
		out_dir = "data/2_trimmed/"
	threads: 1	
	shell:
		"trim_galore "
		"--adapter {params.adapter_seq} "
		"--gzip "
		"--length {params.min_length} "
		"--max_length {params.max_length} "
                        "--output_dir {params.out_dir} "
		"--quality {params.quality} "
		"{input}"

rule filter_rfam:
	input:
		"data/2_trimmed/{sample}_trimmed.fq.gz"
	output:
		"data/3_rfam_filtered/{sample}_rfam_filtered.fq"
	params:
		rfam_genome = config["filter_rfam"]["genome"]
	shell:
			"bowtie "
			"-v 0 "
			"-m 50 "
			"--best "
			"-a "
			"--nomaqround "
			"--norc "
			"--un {output} "
			"{params.rfam_genome} "
			"{input}"	

rule filter_c_m:
	input:
		"data/3_rfam_filtered/{sample}_rfam_filtered.fq"
	output:
		"data/4_c_m_filtered/{sample}_c_m_filtered.fq"
	params:
		c_m_genome = config["filter_c_m"]["genome"]
	shell:
		"bowtie "
		"-v 0 "
		"-m 50 "
		"--best "
		"-a "
		"--nomaqround "
		"--un {output} "
		"{params.c_m_genome} "
		"{input}"

# Working up to here



 
