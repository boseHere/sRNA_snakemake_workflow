#!/usr/bin/python3
"""
Author: Maya Bose
Date: 9/3/2019
Purpose: This program takes an NCBI Taxonomy ID a produces a fasta file 
containing all non-miRNA reads for that species available from the Rfam 
database: https://rfam.xfam.org/
"""
import mysql.connector
import argparse 
import ftplib
import gzip
import io
from io import BytesIO


def get_args():
    """ This function uses the argparse library to parse command line arguments.
    
    Returns:
        args {Namespace} -- Elements of args can be accessed
                     by their option name as attributes (e.g. args.filename 
                     returns the stored input for the filename option)
    """
    parser = argparse.ArgumentParser(description="This script filters reads"
                                                 "within a given range of "
                                                 "lengths, to be used on fastq "
                                                 "files that have already been "
                                                 "adapter-trimmed")
    parser.add_argument("NCBI Species ID", type=str, help="NCBI taxonomy id of \
                                                           species of interest")
    parser.add_argument("--output_dir", nargs="?", type=str, const="./",
                        default="./", help="Directory location for output file."
                                           " Set to current directory by "
                                           "default")
    parser.add_argument("--filename", nargs="?", type=str, const="_rfam_no_\
        mirna.fasta", default="_rfam_no_mirna.fasta", help="Filename with \
                                .fasta extension to write non-mirna reads to")
    args = parser.parse_args()

    return args


def create_connection():
    """This function creates a MySQL connection object to Rfam's public MYSQL
    Database using connection details from their documentation website.
     
    Returns:
        rfam_connect {MySQLConnection} -- A cursor made from this object can be 
        queried to retrieve information from the Rfam public database.
    """
    
    rfam_connect = mysql.connector.connect(
        host="mysql-rfam-public.ebi.ac.uk",
        user="rfamro",
        port=4497,
        db="Rfam"
        )

    return rfam_connect


def get_accession(args, rfam_connect):
    """This function creates a cursor object, then queries the Rfam database for
    non-mirna sequences for the organism whose ncbi taxonomic ID was passed as
    a command line argument. A list of accession numbers containing these 
    sequences is returned.
    
    Arguments:
        args {Namespace} -- Elements of args can be accessed
                     by their option name as attributes (e.g. args.filename 
                     returns the stored input for the filename option)
        rfam_connect {MySQLConnection} -- A cursor made from this object can be 
        queried to retrieve information from the Rfam public database.
    
    Returns:
        results {list} -- A list of unique rfam accession numbers.
    """
    ncbi = getattr(args, "NCBI Species ID")
    rfam_cursor = rfam_connect.cursor()
    query = "SELECT fr.rfam_acc, tx.species\
        FROM full_region fr, family f, rfamseq rf, taxonomy tx \
        WHERE rf.ncbi_id = tx.ncbi_id \
        AND f.rfam_acc = fr.rfam_acc \
        AND fr.rfamseq_acc = rf.rfamseq_acc \
        AND f.type NOT LIKE '%miRNA%' \
        AND rf.ncbi_id = " + ncbi + "\
        AND tx.ncbi_id = " + ncbi 
       
    rfam_cursor.execute(query)
    results = rfam_cursor.fetchall()
    results = list(set(results))
    if results == []:
        print("No information found for the given NCBI ID")
        exit(0)
    species = " ".join(results[0][1].split()[0:2])
    
    return results, species
    

def make_genome(results, species, args):
    """This function iterates through a list of rfam accession numbers, pulls
    their respetive fasta files from the appropriate Rfam daatabase directory,
    and write the lines from these files into a single fasta file.
    
    Arguments:
        results {list} -- A list of unique rfam accession numbers.
        species {str} -- The name of the species corresponding to the given 
                         NCBI taxonomy ID
        args {Namespace} -- Elements of args can be accessed
                     by their option name as attributes (e.g. args.filename 
                     returns the stored input for the filename option)
    """
    if args.filename == "_rfam_no_mirna.fasta":
        o_filename = args.output_dir + getattr(args, "NCBI Species ID") \
                    + args.filename
    else: 
        o_filename = args.output_dir + args.filename
    
    with ftplib.FTP("ftp.ebi.ac.uk") as ftp:
        with open(o_filename, 'w') as outfile:
            ftp.login()
            ftp.cwd("pub/databases/Rfam/CURRENT/fasta_files/")
            for result in results:
                accession = str(result[0]) + ".fa.gz"
                flo = BytesIO()
                ftp.retrbinary("RETR " + accession, flo.write)
                flo.seek(0)
                wrapper = io.TextIOWrapper(gzip.GzipFile(fileobj=flo))
                print_read = False
                for line in wrapper:
                    if line.startswith('>'):
                        if species in line.rstrip():
                            outfile.write(line.rstrip() + "\n")
                            print_read = True
                        else: 
                            print_read = False
                    else:
                        if print_read == True:
                            outfile.write(line.rstrip() + "\n")

                flo.close()


def main():
    args = get_args()
    rfam_connect = create_connection()
    results, species = get_accession(args, rfam_connect)
    print("Species identified as " + species)
    make_genome(results, species, args)


if __name__ == "__main__":
    main()
