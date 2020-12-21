'''
This script maps sequences to D or G clade, depending on nucleotide at position 23403 in aligned SARS-CoV2 genome.
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

    variants = {
            23403 : {
                'variant' : 'spike_614',
                'og_nt' : 'A',
                'new_nt' : 'G',
                'og_aa' : 'D',
                'new_aa' : 'G'
            },
            15406 : {
                'variant' : 'orf1b_647',
                'og_nt' : 'G',
                'new_nt' : 'A',
                'og_aa' : 'A',
                'new_aa' : 'T'
            },
            17671 : {
                'variant' : 'orf1b_1402',
                'og_nt' : 'G',
                'new_nt' : 'T',
                'og_aa' : 'V',
                'new_aa' : 'F'
            },
            17747 : {
                'variant' : 'orf1b_1427',
                'og_nt' : 'C',
                'new_nt' : 'T',
                'og_aa' : 'P',
                'new_aa' : 'L'
            },
            17858 : {
                'variant' : 'orf1b_1464',
                'og_nt' : 'A',
                'new_nt' : 'G',
                'og_aa' : 'Y',
                'new_aa' : 'C'
            },
            27327 : {
                'variant' : 'orf6_42',
                'og_nt' : 'G',
                'new_nt' : 'T',
                'og_aa' : 'K',
                'new_aa' : 'N'
            }
    }

    mapping = {}
    for record in SeqIO.parse(args.alignment, 'fasta'):
        mapping[record.id] = {}
        for pos, dict in variants.items():
            variant = dict['variant']
            if record[pos - 1] == dict['og_nt']:
                mapping[record.id][variant] = dict['og_aa']
            elif record[pos - 1] == dict['new_nt']:
                mapping[record.id][variant] = dict['new_aa']
            else:
                mapping[record.id][variant] = 'other'

    if args.type == 'tsv':
        # Maps strain to clade D or G
        strains = []
        clades = []
        for strain, d_clades in mapping.items():
            strains.append(strain)
            clades.append(d_clades)
        df = pd.DataFrame.from_records(clades, index = strains)
        #Saves mapping as TSV
        with open(args.output, 'w') as f:
            df.to_csv(f, sep = '\t', index_label = 'strain')

    elif args.type == 'json':
        #Saves mapping as JSON
        with open(args.output, 'w') as f:
            json.dump(mapping, f)

    else:
        print('Error: --type must be "json" or "tsv"')
