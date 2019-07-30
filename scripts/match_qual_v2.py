import gzip
i = 0
with open(snakemake.input[0], 'r') as the_file:
    samples = {}
    for line in the_file:
        line = line.strip()

        if i == 0:
            parts = line.split("\t")
            sample = parts[1][5:-13]
            seq_id = parts[0]
            file_a = open("data/8_fastqs/" + str(sample) + ".fastq", "a+")

            if sample not in samples:
                samples[sample] = {}
                qual_file = open("data/4_c_m_filtered/" + str(
                                                sample) + "_c_m_filtered.fq")
                j = 0
                for in_line in qual_file:

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
            seq = samples[sample][seq_id][1]
            qual = samples[sample][seq_id][2]
            seq_id += " "
            seq_id += seq_id_2

            file_a.write(seq_id + "\n")
            file_a.write(seq + "\n")
            file_a.write("+" + "\n")
            file_a.write(qual + "\n")

        i += 1
        if i == 4:
            i = 0
