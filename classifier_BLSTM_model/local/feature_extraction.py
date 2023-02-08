import os
import pickle
import argparse
import configparser

from tqdm import tqdm
from utils import *


# %%
def main(feat_config, filelist, outdir):
    """
    This function just loops over all the elements in the filelist. Extracted features are stored in outdir as pkl file
    with id*.pkl as the file name.

    @param feat_config Configurations of the feature extractor
    @param filelist A scp file with all the audios
    @param outdir Path to the output directory where the feats are stored
    """
    # Make outdir file
    os.makedirs(outdir, exist_ok=True)
    # Read the path of the wav files
    temp = open(filelist).readlines()
    filepaths = {}
    for line in temp:
        idx, path = line.strip().split()
        filepaths[idx] = path
    # Load the Feature Extractor
    FE = FeatureExtractor(feat_config['default'])
    # Making the feats
    featlist = []
    for item in tqdm(filepaths):
        outname = '{}/{}.pkl'.format(outdir, item)
        if not os.path.exists(outname):
            F = FE.extract(filepaths[item])
            with open(outname, 'wb') as f:
                pickle.dump(F, f)
        featlist.append('{} {}/{}.pkl'.format(item, outdir, item))
    # Write the feats path as a .scp file
    with open('{}/feats.scp'.format(outdir), "w") as f:
        for item in featlist:
            f.write(item + '\n')


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--config', '-c', required=True)
    parser.add_argument('--filelist', '-f', required=True)
    parser.add_argument('--outdir', '-o', required=True)
    args = parser.parse_args()

    config = configparser.ConfigParser()
    config.read(args.config)

    main(config, args.filelist, args.outdir)
