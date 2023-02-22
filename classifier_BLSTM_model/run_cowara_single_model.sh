stage=0


results_directory=results_coswara_single_model

train_config=conf/train_config
model_config=conf/model_config
feature_config=conf/feature_config

datadir=data_coswara_all
featsdir=feats_coswara_all

. parse_options.sh

#training a single classifiers with the 9 audio modalities data
if [ $stage -le 0 ];then

	mkdir -p $results_directory
	cp $train_config $results_directory/train_config
	cp $feature_config $results_directory/feature_config
	cp $model_config $results_directory/model_config

	
	result_folder=${results_directory}/
	mkdir -p $result_folder
	echo "=================== Train $audio model============================="

	mkdir -p $result_folder
	python local/train.py -c $results_directory/train_config -m $results_directory/model_config -f $featsdir/dev/feats.scp -t $datadir/train -v $datadir/dev -o $result_folder

	 for item in val test;do
	 	python local/infer.py -c $results_directory/train_config -f $results_directory/feature_config -M $results_directory/model_config -m $result_folder/models/final.pt -i $datadir/${item}.scp -o $result_folder/${item}_coswara_single_model_scores.txt
	 	python local/scoring.py -r $datadir/$item -t $result_folder/${item}_coswara_single_model_scores.txt -o $result_folder/${item}_coswara_single_model_results.pkl
	 done
fi
