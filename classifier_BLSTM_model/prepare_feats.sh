#!/bin/bash

# Replace the path to the wac files with a new path
old_path=$1
new_path=$2

# Check the two arguments are provided
if [ $# -eq 2 ]; then
    echo "Old path: $old_path"
    echo "New path: $new_path"

    for file in `find ./data/ -name "*.scp" -type f`; do
        echo "Processing $file"
        sed -i "s+$old_path+$new_path+g" "$file"
    done
else
  echo "Using the default path of files: home/data/Coswara-Data/extracted_data/"
fi

echo "Make the feats of an audio categories"
for audio_cat in cough-heavy cough-shallow breathing-deep breathing-shallow vowel-a vowel-e vowel-o counting-normal counting-fast;do
  mkdir -p feats/$audio_cat
done

feature_config=conf/feature_config
for dataset in train dev; do
  echo "Processing $dataset"
  python local/feature_extraction.py -c $feature_config -f data/breathing-deep/{$dataset}.scp -o feats/breathing-deep &\
  python local/feature_extraction.py -c $feature_config -f data/breathing-shallow/{$dataset}.scp -o feats/breathing-shallow
  python local/feature_extraction.py -c $feature_config -f data/cough-heavy/{$dataset}.scp -o feats/cough-heavy &\
  python local/feature_extraction.py -c $feature_config -f data/cough-shallow/{$dataset}.scp -o feats/cough-shallow &\
  python local/feature_extraction.py -c $feature_config -f data/counting-normal/{$dataset}.scp -o feats/counting-normal &\
  python local/feature_extraction.py -c $feature_config -f data/counting-fast/{$dataset}.scp -o feats/counting-fast &\
  python local/feature_extraction.py -c $feature_config -f data/vowel-a/{$dataset}.scp -o feats/vowel-a &\
  python local/feature_extraction.py -c $feature_config -f data/vowel-e/{$dataset}.scp -o feats/vowel-e &\
  python local/feature_extraction.py -c $feature_config -f data/vowel-o/{$dataset}.scp -o feats/vowel-o
done
