#!/bin/bash

# Make the feats of an audio category
for audio_cat in breathing-deep counting-normal cough-heavy cough-shallow breathing-deep breathing-shallow vowel-a vowel-e vowel-o counting-normal counting-fast; do
  mkdir -p feats/"$audio_cat"
done

feature_config=conf/feature_config
for dataset in train dev val test1 test2;do
  python local/feature_extraction.py -c $feature_config -f data/breathing-deep/$dataset.scp -o feats/breathing-deep &\
  python local/feature_extraction.py -c $feature_config -f data/breathing-shallow/$dataset.scp -o feats/breathing-shallow
  python local/feature_extraction.py -c $feature_config -f data/cough-heavy/$dataset.scp -o feats/cough-heavy &\
  python local/feature_extraction.py -c $feature_config -f data/cough-shallow/$dataset.scp -o feats/cough-shallow &\
  python local/feature_extraction.py -c $feature_config -f data/counting-normal/$dataset.scp -o feats/counting-normal &\
  python local/feature_extraction.py -c $feature_config -f data/counting-fast/$dataset.scp -o feats/counting-fast &\
  python local/feature_extraction.py -c $feature_config -f data/vowel-a/$dataset.scp -o feats/vowel-a &\
  python local/feature_extraction.py -c $feature_config -f data/vowel-e/$dataset.scp -o feats/vowel-e &\
  python local/feature_extraction.py -c $feature_config -f data/vowel-o/$dataset.scp -o feats/vowel-o
done