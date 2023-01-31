import os
import argparse
from configparser import ConfigParser

from tqdm import tqdm

from models import getNet, torch
from utils import convertType, FeatureExtractor, modify_raw_directory


def inference(model_path: str, file_list: str, output_path: str,
              inference_config: ConfigParser, model_config: ConfigParser, feature_config: ConfigParser,
              device: str = torch.device('cpu')) -> dict:
    """Script to do inference using trained model config, feature_config: model configuration
    and feature configuration files
    :param device: device where the inference take place
    :param model_path: Path to a trained model stored as a .pt file
    :param file_list: List of files as in "<id> <file-path>" format
    :param output_path: output file, its content will be "<id> <probability-score>"
    :param inference_config: Configuration of inference flow
    :param model_config: Configuration of model
    :param feature_config: Configuration of the feature extractor
    :return: A list of id -> labels with a probability score
    """
    print(f'Loading model from {model_path}\n'
          f'Loading file list from {file_list}\n'
          f'Writing output to {output_path}\n'
          f'Using device {device}\n')

    print('Load model parameters')
    model_args = {}
    if model_config is not None:
        for key in model_config['default'].keys():
            model_args[key] = convertType(model_config['default'][key])
    else:
        raise ValueError('Expected an architecture')

    print('Load model, use CPU for inference')
    model = getNet(model_args['architecture'])(model_args)
    model.load_state_dict(torch.load(model_path, map_location='cpu'))
    model = model.to(device)
    model.eval()

    print('Feature extractor')
    FE = FeatureExtractor(feature_config['default'])

    print('Loop over all files')
    scores = {}
    file_list = open(file_list).readlines()
    file_list = [line.strip().split() for line in file_list]

    for fileId, path in tqdm(file_list):
        # Prepare features
        try:
            F = FE.extract(path)
        except IOError:
            print('failed for ' + fileId)
            continue

        if inference_config['training_dataset'].get('apply_mean_norm', False):
            F = F - torch.mean(F, dim=0)
        if inference_config['training_dataset'].get('apply_var_norm', False):
            F = F / torch.std(F, dim=0)
        feat = F.to(device)

        # Input mode
        seg_mode = inference_config['training_dataset'].get('mode', 'file')
        if seg_mode == 'file':
            feat = [feat]
        elif seg_mode == 'segment':
            segment_length = int(inference_config['training_dataset'].get('segment_length', 300))
            segment_hop = int(inference_config['training_dataset'].get('segment_hop', 10))
            feat = [feat[i:i + segment_length, :] for i in range(0, max(1, F.shape[0] - segment_length), segment_hop)]
        else:
            raise ValueError('Unknown eval model')
        with torch.no_grad():
            output = model.predict_proba(feat)

        # Average the scores of all segments from the input file
        scores[fileId] = sum(output)[0].item() / len(output)

    print('Write output scores')
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    with open(output_path, 'w') as f:
        for item in scores:
            f.write(item + " " + str(scores[item]) + "\n")

    return scores


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--file_list', '-i', required=True)  # Path to a .scp file
    parser.add_argument('--output_path', '-o', required=True)  # Path to an output .txt file with the results
    parser.add_argument('--model_path', '-m', required=True)  # Path to model .ptl
    parser.add_argument('--model_config', '-M', required=True)  # Path to model's configuration
    parser.add_argument('--inference_config', '-c', required=True)  # Path to inference's configuration
    parser.add_argument('--feature_config', '-f', required=True)  # Path to featur's configuration

    args = parser.parse_args()

    inf_config = ConfigParser()
    inf_config.read(args.inference_config)

    feat_config = ConfigParser()
    feat_config.read(args.feature_config)

    mdl_config = ConfigParser()
    mdl_config.read(args.model_config)

    inference(args.model_path, args.file_list, args.output_path, inf_config, mdl_config, feat_config)
