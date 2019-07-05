for file in ./../data/genomes/*/*.fasta
do
substring=$(basename $file)
subdir=${file%"$substring"}
bowtie-build -f $file ${substring:0:-6} &&
mv ./*ebwt $subdir
done
