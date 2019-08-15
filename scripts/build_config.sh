# Author: Maya Bose
# Date: 8/7/2019
# Purpose: Automatically adds sample names from /data/1_raw and genome names
# from /genomes to the config file


echo "trimming: " > config.yaml
echo "    min_length : 19" >> config.yaml
echo "    max_length : 26" >> config.yaml
echo "    adapter_seq : TGGAATTCTCGG" >> config.yaml
echo "    quality : 30" >> config.yaml

echo " " >> config.yaml

echo "aligning: " >> config.yaml
echo "    multi_map_handler: u " >> config.yaml
echo "    sort_memory : 20G " >> config.yaml

echo " " >> config.yaml

echo "threads: " >> config.yaml
echo "    filter_rna_bowtie : 10 " >> config.yaml
echo "    filter_c_m_bowtie : 10 " >> config.yaml
echo "    shortstack_cluster : 10 " >> config.yaml
echo "    mapped_reads_samtools : 10 " >> config.yaml
echo "    fastqc_report : 1 " >> config.yaml
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
arr=()
for file in genomes/*/*.fasta; do

    section=$(echo $file | cut -d'/' -f 2)
    name=$(basename $file)
    build=${name%.*}
    if [ "$section" == "filter_rna" ]; then
        echo "    filter_rna : ./genomes/filter_rna/"$build >> config.yaml
        arr+=( "filter_rna" )
    elif [ "$section" == "chloro_mitocondrion" ]; then
        echo "    chloro_mitochondria : ./genomes/chloro_mitocondrion/"$build \
        >> config.yaml
        arr+=( "chloro_mitochondria" )
    elif [ "$section" == "reference_genome" ]; then
        echo "    reference_genome : ./genomes/reference_genome/"$build \
        >> config.yaml
        arr+=( "reference_genome" )
    fi

done
shopt -u nullglob

function contains() {
    local n=$#
    local value=${!n}
    for ((i=1;i < $#;i++)) {
        if [ "${!i}" == "${value}" ]; then
            echo "y"
            return 0
        fi
    }
    echo "n"
    return 1
}


if [ $(contains "${arr[@]}" "filter_rna") == "n" ]; then
    echo
    echo "    filter_rna : ./genomes/filter_rna/ " >> config.yaml
    echo Alert: No genome found in the /genome/filter_rna directory. This \
         filter is optional and will not prevent the pipeline from running. \
         However, if the user intends to utilise this filtering step, it is \
         advised to check that the genome is in the correct location in the \
         directory structure, in the form of a fasta file.
fi
if [ $(contains "${arr[@]}" "chloro_mitochondria") == "n" ]; then
    echo
    echo WARNING: No genome found in the /genome/chloro_mitchondira \
    directory. This filter is REQUIRED for this pipeline, and the pipeline \
    will not be able to run correctly without it. It is advised that the user \
    check that the genome containing chloroplast and mitochondria reads is in \
    the correct location in the directory structure, in the form of a fasta \
    file.
fi
if [ $(contains "${arr[@]}" "reference_genome") == "n" ]; then
    echo
    echo WARNING: No genome found in the /genome/reference_genome directory. \
    This filter is REQUIRED for this pipeline, and the pipeline will not be \
    able to run correctly without it. It is advised that the user check that \
    the reference genome is in the correct location in the directory \
    structure, in the form of a fasta file.
fi
