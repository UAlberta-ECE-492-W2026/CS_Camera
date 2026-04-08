%==========================================================================
% SCRIPT_NAME: test_single_image.m
%==========================================================================
clear; clc; close all;

% 1. Setup
% 1. Setup
% Resolve paths dynamically based on the script's location
currentScriptDir = fileparts(mfilename('fullpath'));
projectRoot = fileparts(currentScriptDir); % Step out of '+tools'

% Load the trained model from the '+models' directory
modelPath = fullfile(projectRoot, '+models', 'cs_enhancement_net_CNN.mat');
load(modelPath, 'net');

% Load configuration from the 'configs' directory
configPath = fullfile(projectRoot, 'configs', 'camera_settings.json');
cfg = utils.loadConfig(configPath);
resValue = cfg.sampling_parameters.resolution(1);

maskList = utils.selectMaskIndexes(utils.getOptimalCore([resValue, resValue], ...
    cfg.sampling_parameters.core_mask_count), cfg.sampling_parameters.sampling_pct, [resValue, resValue]);

% 2. Load and crop image
imagePath = fullfile(projectRoot, 'images', 'penguin.tiff');
rawImg = imread(imagePath);
if size(rawImg, 3) >= 3
    rawImg = im2gray(rawImg(:, :, 1:3));
end

[rows, cols] = size(rawImg);
win = centerCropWindow2d([rows, cols], [min(rows, cols), min(rows, cols)]);
original_high_res = imcrop(rawImg, win);

% 3. The Pipeline (Using YOUR Helpers!)

% Step A: Hardware Simulation (Forward)
% camera_data includes the -1 resolution metadata row
[camera_data, ground_truth] = utils.emulateCameraCapture(original_high_res, cfg, maskList);

% Step B: Simple Reconstruction (Backward)
% Pass the raw data directly into your existing reco function
simple_recon = reco.simpleReconstruction(camera_data);

% Step C: CNN Enhancement
cnn_enhanced = predict(net, simple_recon);

% 4. Display
figure('Name', 'Pipeline Validation', 'Position', [100, 200, 1200, 350]);
subplot(1,4,1); imshow(original_high_res); title('Original');
subplot(1,4,2); imshow(ground_truth); title(sprintf('Target (%dx%d)', resValue, resValue));
subplot(1,4,3); imshow(simple_recon); title('Simple Recon');
subplot(1,4,4); imshow(cnn_enhanced); title('CNN Output');
colormap gray;