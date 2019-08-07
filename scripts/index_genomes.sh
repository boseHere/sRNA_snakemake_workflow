#!/bin/bash
Author: Maya Bose
Purpose: Index .fasta genome files 

for file in genomes/*/
do
	num_files=`ls -l $file | grep ".ebwt$" | wc -l`

	if [ $num_files -lt 6 ]
		then

		for f_file in $file*.fasta
		do
			substring=$(basename $file) 
			subdir=${file%"$substring"} 
			build_name=$(basename $f_file)
			bowtie-build -f $f_file ${build_name:0:${#build_name} - 6} &&
			mv ./${build_name:0:${#build_name} - 6}*.ebwt $subdir
		done
	fi

done
