#!/usr/bin/env python3

# Author: Jeffrey Grover
# Purpose: Count the number of reads of each size in a .fastq
# Created: 02/2019

from argparse import ArgumentParser

# Define a function to iterate through the .fastq and profile the reads


def fastq_length_profile(input_fastq):
    fastq_lengths_dict = {}
    with open(input_fastq) as input_handle:
        n = 0
        for line in input_handle:
            n += 1
            seq_length = len(line.strip())
            if n == 2 and seq_length not in fastq_lengths_dict:
                fastq_lengths_dict[seq_length] = 1
            elif n == 2 and seq_length in fastq_lengths_dict:
                fastq_lengths_dict[seq_length] += 1
            elif n == 4:
                n = 0
    return fastq_lengths_dict


def output_fastq_lengths(input_fastq_lengths_dict, input_fastq):
    print(str(input_fastq)[14:] + " read length profile:")
    print('length', 'count', sep='\t')
    for seq_length, count in sorted(input_fastq_lengths_dict.items()):
        print(seq_length, count, sep='\t')


# Parse command line options

parser = ArgumentParser(
    description='Counts the different lengths of reads in a .fastq file.')
parser.add_argument('fastq', help='Input .fastq', metavar='File')

input_fastq = parser.parse_args().fastq

# Parse and count

output_fastq_lengths(fastq_length_profile(input_fastq), input_fastq)
