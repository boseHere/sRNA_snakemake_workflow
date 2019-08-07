# Author: Maya Bose
# Date: 8/7/2019
# Purpose: Automatically adds sample names from /data/1_raw and genome names from /genomes to the config file


echo "trimming: " > config.yaml
echo "    min_length : 19" >> config.yaml
echo "    max_length : 26" >> config.yaml
echo "    adapter_seq : TGGAATTCTCGG" >> config.yaml
echo "    quality : 30" >> config.yaml

echo " " >> config.yaml

echo "threads: " >> config.yaml
echo "    filter_rna_bowtie : 10 " >> config.yaml
echo "    filter_c_m_bowtie : 10 " >> config.yaml
echo "    shortstack_cluster : 10 " >> config.yaml
echo "    mapped_reads_samtools : 10 " >> config.yaml

echo " " >> config.yaml

echo "paths: " >> config.yaml
echo "    trim_galore : trim_galore" >> config.yaml
echo "    bowtie : bowtie" >> config.yaml
echo "    ShortStack : ShortStack" >> config.yaml
echo "    samtools : samtools" >> config.yaml

echo " " >> config.yaml

echo "samples: " >> config.yaml
shopt -s nullglob
for file in data/1_raw/*.{fastq,fastq.gz,fq.gz,fq}; do
	name=$(basename $file)
	sample=${name%%.*}
	echo "    - "$sample >> config.yaml
done
shopt -u nullglob

echo " " >> config.yaml

echo "genomes: " >> config.yaml
shopt -s nullglob
for file in genomes/*/*.fasta; do

	section=$(echo $file | cut -d'/' -f 2)
	name=$(basename $file)
	build=${name%%.*}
	if [ "$section" == "filter_rna" ]; then
		echo "    filter_rna : ./genomes/filter_rna/"$build >> config.yaml
	elif [ "$section" == "chloro_mitocondrion" ]; then
		echo "    chloro_mitochondria : ./genomes/chloro_mitocondrion/"$build >> config.yaml
	elif [ "$section" == "reference_genome" ]; then
		echo "    reference_genome : ./genomes/reference_genome/"$name >> config.yaml
	fi

done
shopt -u nullglob



