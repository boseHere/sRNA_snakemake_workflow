
"""
split_fastq_to_fastas.py
Author: Maya Bose
Date: 5/30/19
Purpose: Given one fastq file containing reads for multiple sample origins,
converts reads to fasta format and puts reads from unique samples into
their own fasta file.
"""


i = 0
with open(snakemake.input[0], 'r') as the_file:
    samples = {}
    for line in the_file:
        line = line.strip()

        if i == 0:
            line = '>' + line[1:]  # Changes fastq '@' character to fasta
            # '>' character
            parts = line.split("\t")
            sample = parts[1][5:-13]
            file_a = open("data/7_fastas/" + str(sample) + ".fasta", "a+")
            file_a.write(parts[0] + "\n")

        elif i == 1:
            try:
                file_a.write(line + "\n")
                file_a.close()
            except:
                pass

        i += 1
        if i == 4:
            i = 0


