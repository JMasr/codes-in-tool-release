#!/bin/bash

# Make the feats of an audio categori
audioArray=("breathing-deep" "breathing-shallow" "cough-heavy" "cough-shallow" "counting-normal" "counting-fast" "vowel-a" "vowel-e" "vowel-o")
for audio_cat in ${audioArray[@]}; do
  mkdir -p feats/$audio_cat
done

feature_config=conf/feature_config
python local/FeatureExtractor.py -c $feature_config -f data/breathing-deep/dev.scp -o feats/breathing-deep &\
python local/FeatureExtractor.py -c $feature_config -f data/breathing-shallow/dev.scp -o feats/breathing-shallow
python local/FeatureExtractor.py -c $feature_config -f data/cough-heavy/dev.scp -o feats/cough-heavy &\
python local/FeatureExtractor.py -c $feature_config -f data/cough-shallow/dev.scp -o feats/cough-shallow &\
python local/FeatureExtractor.py -c $feature_config -f data/counting-normal/dev.scp -o feats/counting-normal &\
python local/FeatureExtractor.py -c $feature_config -f data/counting-fast/dev.scp -o feats/counting-fast &\
python local/FeatureExtractor.py -c $feature_config -f data/vowel-a/dev.scp -o feats/vowel-a &\
python local/FeatureExtractor.py -c $feature_config -f data/vowel-e/dev.scp -o feats/vowel-e &\
python local/FeatureExtractor.py -c $feature_config -f data/vowel-o/dev.scp -o feats/vowel-o