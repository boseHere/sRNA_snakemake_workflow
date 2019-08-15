#!/usr/bin/env python3
import argparse
import gzip

def main():
    d = get_args()
    trim(d)


def get_args():
    parser = argparse.ArgumentParser(description="Take sRNA seq run; trims"
                                                 "1 base off the 3' end")
    parser.add_argument('sRNA file', metavar='n', type=str, nargs=1,
                        help='The sRNA seq filename')
    parser.add_argument('output file', metavar='o', type=str, nargs=1,
                        help='The file to be written to')
    args = parser.parse_args()
    d = vars(args)
    return d


def trim(d):
    with gzip.open(d['sRNA file'][0], 'r') as sfile:
        with open(d['output file'][0], 'w+') as outfile:
            i = 0
            for line in sfile:
                line = line.decode('utf-8')
                if i == 1 or i == 3:
                    line = line.strip()
                    if len(line) == 23:
                        line = line[:-1]
                    line += "\n"
                outfile.write(line)
                i += 1
                if i == 4:
                    i = 0

main()
