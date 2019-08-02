cat config1.yaml > config.yaml

for file in data/1_raw/*[.fastq.gz | .fq.gz | .fq | .fq.gz]
do
name=$(basename $file)
sample=${name%%.*}
echo    - $sample

cat config2.yaml >> config.yaml
