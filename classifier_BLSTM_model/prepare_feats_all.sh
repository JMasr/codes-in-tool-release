#!/bin/bash

# Replace the path to the wac files with a new path
old_path=$1
new_path=$2

# Check the two arguments are provided
if [ $# -eq 2 ]; then
    echo "Old path: $old_path"
    echo "New path: $new_path"

    for file in `find ./data_coswara_all/all -name "*.scp" -type f`; do
        echo "Processing $file"
        sed -i "s+$old_path+$new_path+g" "$file"
    done
else
  echo "Using the default path of files: home/data/Coswara-Data/extracted_data/"
fi

repo_path=$(pwd)
feature_config=$repo_path/conf/feature_config
for dataset in train dev test; do
  echo "Processing $dataset"
  python local/feature_extraction.py -c $feature_config -f $repo_path/data_coswara_all/all/$dataset.scp -o $repo_path/feats_coswara_all/$dataset
done
