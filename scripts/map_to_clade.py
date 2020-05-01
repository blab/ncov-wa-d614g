'''
This script maps sequences to D or G clade, depending on nucleotide at position 23402 in aligned SARS-CoV2 genome.
Inputs are:
--alignment
--output
--type (output format, must be either json or tsv)
'''

import argparse
from Bio import SeqIO
import pandas as pd
import json

if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description="Subsamples strains over time",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter
    )

    parser.add_argument('--alignment', type=str, required=True, help='alignment of viruses')
    parser.add_argument('--output', type=str, required=True, help = 'location of output json')
    parser.add_argument('--type', type=str, required=True, help = 'specifies output format, either json or tsv')
    args = parser.parse_args()


if args.type == 'tsv':
    # Maps strain to clade D or G
    df = pd.DataFrame()
    for record in SeqIO.parse(args.alignment, 'fasta'):
        if record[23402] == 'A':
            df = df.append({'strain' : record.id, 'clade' : 'D'}, ignore_index=True)
        elif record[23402] == 'G':
            df = df.append({'strain' : record.id, 'clade' : 'G'}, ignore_index=True)
        else:
            df = df.append({'strain' : record.id, 'clade' : 'other'}, ignore_index=True)

    #Saves mapping as TSV
    with open(args.output, 'w') as f:
        df.to_csv(f, sep = '\t', index=False)

elif args.type == 'json':
    # Maps strain to clade D or G
    mapping = {}
    for record in SeqIO.parse(args.alignment, 'fasta'):
        mapping[record.id] = {}
        if record[23402] == 'A':
            mapping[record.id]['clade'] = 'D'
        elif record[23402] == 'G':
            mapping[record.id]['clade'] = 'G'
        else:
            mapping[record.id]['clade'] = 'other'

    #Saves mapping as JSON
    with open(args.output, 'w') as f:
        json.dump(mapping, f)

else:
    print('Error: --type must be "json" or "tsv"')
