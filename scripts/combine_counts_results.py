#!/usr/bin/python3
"""
Author: Maya Bose
Date: 8/13/19
Purpose: Takes the Counts.txt and Results.txt files output by ShortStack
and outputs three text files that combine the information of the two inputs.
The first file contains the combined information in counts. The second file
contains the combined information in RPM. The third file contains the
combined information in RPKM.
"""
__author__ = "boseHere"
import argparse

def get_args():
    """
    This function uses the argparse library to parse command line arguments.
    :param: none
    :return: args -- An argparse object. Elements of the object can be accessed
                     by their option name as attributes)
    """
    parser = argparse.ArgumentParser(description="This script takes the "
                                                 "Counts.txt and Results.txt "
                                                 "files output by ShortStack "
                                                 "and outputs three text files "
                                                 "that combine the information "
                                                 "of the two inputs.")
    parser.add_argument("counts", type=str, help="Counts.txt file name")
    parser.add_argument("results", type=str, help="Results.txt file name")

    args = parser.parse_args()
    return args


def get_library_sizes(counts):
    """
    This function takes the Counts.txt file as input. It generates a list of
    library sizes, to be used in the calculation of rpm and rpkm.
    :param: counts -- An open Counts.txt file
    :return: library_sizes -- A list of lists, where each element of the list
                     contains the name of a library and the size of
                     that library
    """
    sizes = []
    head = True
    for line in counts:
        line = line.strip()
        if head:
            head = False
            samples = line.split("\t")[3:]
            total_counts = [0] * len(samples)
        else:
            counts = line.split("\t")[3:]
            for i in range(len(counts)):
                total_counts[i] += int(counts[i])

    for i in range(len(samples)):
        sizes.append([samples[i], total_counts[i]])

    return sizes


def combine(args, library_sizes):
    """
    This function takes as input the Counts.txt file, the Results.txt file, and a list
    containing library sizes, ordered in the same order they appear in the
    input files. It opens the three output files for writing, creates and
    writes the combined header, then processes each file one line at a time.
    :params: args -- An argparse object. Elements of the object can be accessed
                     by their option name as attributes)
             library_sizes -- A list of lists, where each element of the list
                              contains the name of a library and the size of
                              that library
    :return: none
    """
    with open(args.counts, "r") as counts, open(args.results, "r") as results:
        with open("./counts_results.txt", "w+") as file1, \
                open("./counts_results_rpm.txt","w+") as file2, \
                open("./counts_results_rpkm.txt", "w+") as file3:
            head = True
            for count_line, results_line in zip(counts, results):
                count_line = count_line.strip()
                results_line = results_line.strip()

                if head:  # Process column names into one header
                    head = False
                    count_head_parts = count_line.split("\t")
                    results_head_parts = results_line.split("\t")
                    results_head_parts = ["Chromosome", "Start", "End"] + \
                                        results_head_parts[1:]

                    new_head_parts = results_head_parts + \
                                    count_head_parts[2:]
                    new_head = "\t".join(new_head_parts)
                    new_head += "\n"
                    file1.write(new_head)
                    file2.write(new_head)
                    file3.write(new_head)

                else:
                    process(count_line, results_line,
                            file1, file2, file3, library_sizes)


def process(cline, rline, file1, file2, file3, library_sizes):
    """
    This function takes one line of data for the same locus from Counts.txt and
    Results.txt, the three output files, and a list of library sizes. Using
    the locus size (from Results.txt), the number of mapped reads for that
    locus for a given library (from Counts.txt), and the total number of
    mapped reads for that library (from library_sizes), RPM and RPKM are
    calculated. These values are written to their respective output file.
    :params: cline -- A line of data from Counts.txt
             rline -- A line of data from Results.txt
             file1 -- The output file for counts in number of reads
             file2 -- The output file for counts in RPM
             file3 -- The output file for counts in RPKM
             library_sizes -- A list of lists, where each element of the list
                              contains the name of a library and the size of
                              that library
    :return: none
    """
    cparts = cline.split("\t")
    rparts = rline.split("\t")

    # confirm that the two lines being processed are for the same locus
    assert(cparts[0] == rparts[0] and cparts[1] == rparts[1])

    # split first column (locus) into three columns containing its
    # consituent parts (chromosome, start base, and end base)
    chr = rparts[0].split(":")[0]
    start = rparts[0].split(":")[1].split("-")[0]
    end = rparts[0].split(":")[1].split("-")[1]

    line1 = [chr, start, end] + rparts[1:] + cparts[2:] # counts in reads
    line2 = [chr, start, end] + rparts[1:] + [cparts[2]] # counts in rpm
    line3 = [chr, start, end] + rparts[1:] + [cparts[2]] # counts in rpkm

    gene_length = int(rparts[2])

    for i in range(3, len(cparts)):

        index = i - 3
        lib_size = library_sizes[index][1]

        mapped_reads = int(cparts[i])

        if lib_size == 0: # Prevent DIVBYZERO error
            rpm = 0
            rpkm = 0
        elif gene_length == 0:
            rpkm = 0
        else:
            rpm = ((mapped_reads * (10 ** 6)) / lib_size)
            rpkm = ((mapped_reads * (10 ** 9)) / (lib_size * gene_length))

        line2 += [str(rpm)]
        line3 += [str(rpkm)]

    out1 = "\t".join(line1) + "\n"
    out2 = "\t".join(line2) + "\n"
    out3 = "\t".join(line3) + "\n"

    file1.write(out1)
    file2.write(out2)
    file3.write(out3)


def main():
    args = get_args()
    with open(args.counts, "r") as counts:
        library_sizes = get_library_sizes(counts)
    combine(args, library_sizes)


if __name__ == "__main__":
    main()
