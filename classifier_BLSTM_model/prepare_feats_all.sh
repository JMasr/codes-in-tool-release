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
for dataset in train dev test; do
  echo "Processing $dataset"
  python local/feature_extraction.py -c $feature_config -f data_coswara_all/all/$dataset.scp -o feats_coswara_all/$dataset
done
