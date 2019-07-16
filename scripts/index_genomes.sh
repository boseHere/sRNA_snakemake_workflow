#!/bin/bash
for file in data/genomes/*/
do
	num_files=`ls -l $file | grep ".ebwt$" | wc -l`

	if [ $num_files -lt 6 ]
		then

		for f_file in $file*.fasta
		do
			substring=$(basename $file) 
			subdir=${file%"$substring"} 
			bowtie-build -f $f_file ${f_file:24:-6} &&
			mv ./${f_file:24:-6}*.ebwt $subdir
		done
	fi

done
