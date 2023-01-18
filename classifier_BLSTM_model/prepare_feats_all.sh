# feature_config should be conf/feature_config.
#
# scp shd be a data/<audio-cat>/dev.scp  (e.g data/breathing-deep.scp/dev.scp).
#
# finally,outdir shd be feats/<audio_cat> (e.g. feats/breathing-deep)
#
#so, this code shd be run seperately for 9 audio categories (breathing-deep etc.)

outdir=feats
feature_config=conf/feature_config
scpArray=("breathing-deep" "breathing-shallow" "cough-heavy" "cough-shallow" "vowel-a" "vowel-e" "vowel-o" "counting-normal" "counting-fast")



for scp in ${scpArray[@]}; do
  mkdir -p $outdir/scp
  python local/feature_extraction.py -c $feature_config -f data/$scp/dev.scp -o $outdir/scp  
done
