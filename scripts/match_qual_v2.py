#!/usr/bin/python3
"""
Author: Maya Bose
Purpose: Interacts with input from the Mosher Lab sRNA Snakemake Workflow.
After alignment and conversion to fastq, quality encoding becomes degraded.
This script matches sequences from post-conversion fastq files to
pre-conversion fastq files using sequence identifiers. It then replaces the
degraded quality encoding with the intact quality encoding from the
pre-conversion fastq file.
"""
__author__ = "boseHere"

import gzip
def retrieve_encoding_quality():
    i = 0
    with open(snakemake.input[0], 'r') as the_file:
        samples = {}
        for line in the_file:

            line = line.strip()
            if i == 0:
                parts = line.split("\t")
                sample = parts[1][5:-13]
                seq_id = parts[0]
                file_a = gzip.open("data/7_fastqs/" + str(sample) + ".fastq.gz",
                "a+")

                if sample not in samples:
                    samples[sample] = {}
                    qual_file = gzip.open("data/4_c_m_filtered/" + str(
                    sample) + "_c_m_filtered.fq.gz")
                    j = 0
                    for in_line in qual_file:
                        in_line = in_line.decode("utf-8")
                        in_line = in_line.strip()
                        if j == 0:
                            in_parts = in_line.split()
                            seq_id_in = in_parts[0]
                            seq_id_2 = in_parts[1]
                        elif j == 1:
                            seq = in_line
                        elif j == 3:
                            qual = in_line
                            samples[sample][seq_id_in] = [seq_id_2, seq, qual]
                        j += 1
                        if j == 4:
                            j = 0

                seq_id_2 = samples[sample][seq_id][0]
                seq = samples[sample][seq_id][1] + '\n'
                qual = samples[sample][seq_id][2] + '\n'
                seq_id += " " + seq_id_2 + '\n'

                line1 = seq_id.encode("utf-8")
                line2 = seq.encode("utf-8")
                line3 = "+\n".encode("utf-8")
                line4 = qual.encode("utf-8")

                file_a.write(line1)
                file_a.write(line2)
                file_a.write(line3)
                file_a.write(line4)

            i += 1
            if i == 4:
                i = 0

def main():
    retrieve_encoding_quality()

if __name__ == "__main__":
    main()
