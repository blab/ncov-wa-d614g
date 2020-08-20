'''
Joins multiple tsv files and clades into single dataframe.
Inputs are:
--clades (json)
--data (list of tsv files
--source, source tsv is from
--metadata
--output
'''

import argparse
import json
import pandas as pd

def make_df(data, source):
    '''
    Combines multiple data tsv files into one dataframe
    '''
    df = pd.DataFrame()
    for m,s in zip(data, source):
        m_df = pd.read_csv(m, sep = '\t')
        m_df['source'] = s
        df = df.append(m_df)
    df = df.set_index('strain')
    return df

def add_clade(clades, df):
    '''
    Adds clades for each strain in dataframe
    '''
    with open(clades) as jfile:
        clades_dict = json.load(jfile)
    for strain, row in df.iterrows():
        if strain in clades_dict.keys():
            df.loc[strain, 'clade'] = clades_dict[strain]['clade']
    return df

def add_metadata(df, metadata):
    '''
    Adds metadata from ncov build to df.
    '''
    meta = pd.read_csv(metadata, sep = '\t')
    df = df.merge(meta[['strain', 'date', 'division', 'location']], how = 'left', left_index = True, right_on = 'strain')
    df = df.set_index('strain')
    return df

if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description="Subsamples strains over time",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter
    )

    parser.add_argument('--clades', type=str, required=True, help='JSON with clade & strain')
    parser.add_argument('--data', type=str, nargs='+', required=True, help='TSV metadata for UW sequences')
    parser.add_argument('--source', type=str, nargs='+', required=True, help='Source of metadata')
    parser.add_argument('--output', type=str, required=True, help = 'location of output json')
    parser.add_argument('--metadata', type=str, required=True, help = 'Metadata from ncov build')
    args = parser.parse_args()

# Combines metadata into one dataframe
data = make_df(args.data, args.source)

# Adds clades to df
combined = add_clade(args.clades, data)

# Adds metadata from ncov build to df
combined_meta = add_metadata(combined, args.metadata)

# Write df to tsv
combined_meta.to_csv(args.output, sep = '\t')
