%==========================================================================
% SCRIPT_NAME:  test_single_image.m
%
% PURPOSE:      Simulates the complete compressive sensing pipeline on a 
%               single test image. Processes an input image through hardware 
%               capture emulation, simple reconstruction, and CNN-based 
%               enhancement to validate the system end-to-end.
%
% AUTHOR:       Cole Mckay (cdmckay1@ualberta.ca)
% DATE:         April 10, 2026
% VERSION:      1.0
%
% NOTES:        Requires a trained ResNet model ('cs_enhancement_net_ResNet.mat') 
%               and configuration settings ('camera_settings.json'). Evaluates 
%               the pipeline visually using a 4-panel subplot comparing the 
%               original, target, simple reconstruction, and CNN output.
%==========================================================================

clear; clc; close all;


% Resolve paths dynamically based on the script's location
currentScriptDir = fileparts(mfilename('fullpath'));
projectRoot = fileparts(currentScriptDir); % Step out of '+tools'

% Load the trained model from the '+models' directory
modelPath = fullfile(projectRoot, '+models', 'cs_enhancement_net_ResNet.mat');
load(modelPath, 'net');

% Load configuration from the 'configs' directory
configPath = fullfile(projectRoot, 'configs', 'camera_settings.json');
cfg = utils.loadConfig(configPath);
resValue = cfg.sampling_parameters.resolution(1);

maskList = utils.selectMaskIndexes(utils.getOptimalCore([resValue, resValue], ...
    cfg.sampling_parameters.core_mask_count), cfg.sampling_parameters.sampling_pct, [resValue, resValue]);

% Load and crop image
imagePath = fullfile(projectRoot, 'images', 'penguin.tiff');
rawImg = imread(imagePath);
if size(rawImg, 3) >= 3
    rawImg = im2gray(rawImg(:, :, 1:3));
end

[rows, cols] = size(rawImg);
win = centerCropWindow2d([rows, cols], [min(rows, cols), min(rows, cols)]);
original_high_res = imcrop(rawImg, win);

% The Pipeline

% Step A: Hardware Simulation (Forward)
% camera_data includes the -1 resolution metadata row
[camera_data, ground_truth] = utils.emulateCameraCapture(original_high_res, cfg, maskList);

% Step B: Simple Reconstruction (Backward)
% Pass the raw data directly into reco function
simple_recon = reco.simpleReconstruction(camera_data);

% Step C: CNN Enhancement
cnn_enhanced = predict(net, simple_recon);

% 4. Display
figure('Name', 'Pipeline Validation', 'Position', [100, 200, 1200, 350]);

titleFontSize = 22; 

subplot(1,4,1); imshow(original_high_res); 
title('Original', 'FontSize', titleFontSize);

subplot(1,4,2); imshow(ground_truth); 
title(sprintf('Target (%dx%d)', resValue, resValue), 'FontSize', titleFontSize);

subplot(1,4,3); imshow(simple_recon); 
title('Simple Recon', 'FontSize', titleFontSize);

subplot(1,4,4); imshow(cnn_enhanced); 
title('CNN Output', 'FontSize', titleFontSize);

colormap gray;