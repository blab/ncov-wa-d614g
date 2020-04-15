'''
This script maps sequences to G or S clade, depending on nucleotide at position 23403 in aligned SARS-CoV2 genome.
Inputs are:
--alignment
--output
'''

import argparse
from Bio import SeqIO
import json

if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description="Subsamples strains over time",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter
    )

    parser.add_argument('--alignment', type=str, required=True, help='alignment of viruses')
    parser.add_argument('--output', type=str, required=True, help = 'location of output json')
    args = parser.parse_args()

# Maps strain to clade S or G
mapping = {}
for record in SeqIO.parse(args.alignment, 'fasta'):
    mapping[record.id] = {}
    if record[23402] == 'A':
        mapping[record.id]['clade'] = 'S'
    elif record[23402] == 'G':
        mapping[record.id]['clade'] = 'G'
    else:
        mapping[record.id]['clade'] = 'other'

#Saves mapping as JSON
with open(args.output, 'w') as f:
    json.dump(mapping, f)
