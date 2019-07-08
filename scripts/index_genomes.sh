#!/bin/bash
for file in data/genomes/*/
do
num_files=`ls -l $file | grep ".ebwt$" | wc -l`

if [ $num_files -lt 6 ]
then
new_file=$file*.fasta
substring=$(basename $file)
subdir=${file%"$substring"}
echo $substring
echo $subdir
bowtie-build -f $new_file ${substring} &&
mv ./$substring*.ebwt $subdir
fi

done
