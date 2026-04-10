%==========================================================================
% SCRIPT_NAME:  train_CS_Enhancement_CNN.m
%
% PURPOSE:      Loads the Compressive Sensing dataset, applies linear 
%               projection to raw measurements, and trains a residual CNN 
%               to map noisy reconstructions to ground truth images.
%
% AUTHOR:       Cole Mckay (cdmckay1@ualberta.ca)
% DATE:         April 10, 2026
% VERSION:      1.0
%
% NOTES:        Requires 'cnn_training_data_50p.mat' and configuration 
%               settings. Saves the trained ResNet model to the '+models' 
%               directory for use in the main processing pipeline.
%==========================================================================

clear; clc; close all;
parallel.gpu.enableCUDAForwardCompatibility(true);

% Resolve paths dynamically based on the script's location
currentScriptDir = fileparts(mfilename('fullpath'));
projectRoot = fileparts(currentScriptDir); % Step up to root
dataDir = fullfile(projectRoot, 'data');

fprintf('Loading training dataset...\n');
% Load the data from the 'data' folder
dataPath = fullfile(dataDir, 'cnn_training_data_50p.mat');
load(dataPath, 'X_train_raw', 'Y_train', 'maskList');

% Load configuration from the 'configs' directory
configPath = fullfile(projectRoot, 'configs', 'camera_settings.json');
cfg = utils.loadConfig(configPath);
resValue = cfg.sampling_parameters.resolution(1);
res = [resValue, resValue];
numPixels = resValue * resValue;
numMasks = length(maskList);
numImages = size(X_train_raw, 4);

fprintf('Building the Sensing Matrix (Phi)...\n');
Phi = zeros(numMasks, numPixels);
for i = 1:numMasks
    mask = double(utils.generateWalshMask(maskList(i), res));
    Phi(i, :) = mask(:)';
end

fprintf('Projecting raw 1D measurements into 2D initial guesses...\n');
X_train_2D = zeros(resValue, resValue, 1, numImages);
for i = 1:numImages
    % Extract the 1D ADC values for this image and remove DC baseline
    y = squeeze(X_train_raw(:, 1, 1, i));
    y = y - mean(y); 
    
    % Linear back-projection
    x_initial = Phi' * y;
    
    % Reshape to 2D and normalize
    img_guess = reshape(x_initial, [resValue, resValue]);
    img_guess = img_guess - min(img_guess(:));
    if max(img_guess(:)) > 0
        img_guess = img_guess / max(img_guess(:));
    end
    
    X_train_2D(:, :, 1, i) = img_guess;
end

fprintf('Defining CNN Architecture...\n');
% Base layers definition
layers = [
    imageInputLayer([resValue resValue 1], 'Name', 'InputLayer', 'Normalization', 'none')
    
    % Layer 1: Patch extraction and representation
    convolution2dLayer(9, 64, 'Padding', 'same', 'Name', 'Conv1')
    reluLayer('Name', 'ReLU1')
    
    % Layer 2: Non-linear mapping
    convolution2dLayer(5, 32, 'Padding', 'same', 'Name', 'Conv2')
    reluLayer('Name', 'ReLU2')
    
    % Layer 3: Reconstruction
    convolution2dLayer(5, 1, 'Padding', 'same', 'Name', 'OutputLayer')
    
    regressionLayer('Name', 'RegressionLoss')
];

% 1. Initialize layer graph for residual network
lgraph = layerGraph();

% 2. Add main input layer
lgraph = addLayers(lgraph, imageInputLayer([resValue resValue 1], 'Name', 'Input', 'Normalization', 'none'));

% 3. Create the Residual Branch to isolate Walsh-Hadamard artifacts
artifactBranch = [
    convolution2dLayer(5, 64, 'Padding', 'same', 'Name', 'Conv1')
    reluLayer('Name', 'ReLU1')
    convolution2dLayer(3, 32, 'Padding', 'same', 'Name', 'Conv2')
    reluLayer('Name', 'ReLU2')
    convolution2dLayer(5, 1, 'Padding', 'same', 'Name', 'Conv3')
];
lgraph = addLayers(lgraph, artifactBranch);

% 4. Add combination and loss layers
lgraph = addLayers(lgraph, additionLayer(2, 'Name', 'Add'));
lgraph = addLayers(lgraph, regressionLayer('Name', 'Loss'));

% 5. Connect the network layers
% Connect input to the start of the artifact branch
lgraph = connectLayers(lgraph, 'Input', 'Conv1');
% Bypass convolutions to pass original image straight to addition layer
lgraph = connectLayers(lgraph, 'Input', 'Add/in1');
% Pass isolated artifacts to addition layer
lgraph = connectLayers(lgraph, 'Conv3', 'Add/in2');
% Output combined image to loss calculator
lgraph = connectLayers(lgraph, 'Add', 'Loss');

% Set training options
options = trainingOptions('adam', ...
    'InitialLearnRate', 1e-3, ...
    'MaxEpochs', 50, ...
    'MiniBatchSize', 64, ...
    'Shuffle', 'every-epoch', ...
    'Plots', 'training-progress', ...
    'ExecutionEnvironment', 'gpu', ...
    'Verbose', false);

fprintf('Starting network training...\n');
% Train the network
net = trainNetwork(X_train_2D, Y_train, lgraph, options);

% Save the network
modelsDir = fullfile(projectRoot, '+models');
if ~exist(modelsDir, 'dir')
    mkdir(modelsDir);
    fprintf('Created missing directory: %s\n', modelsDir);
end

outputModelPath = fullfile(modelsDir, 'cs_enhancement_net_ResNet_50p.mat');
save(outputModelPath, 'net');
fprintf('Training complete! Network saved as: %s\n', outputModelPath);

% --- Visual Validation on a Training Sample ---
% Extract the first image array to validate enhancement visually
test_input = X_train_2D(:, :, 1, 1);
ground_truth = Y_train(:, :, 1, 1);
test_output = predict(net, test_input);

figure('Name', 'CNN Enhancement Validation', 'Position', [200, 200, 1000, 400]);

subplot(1, 3, 1);
imshow(ground_truth);
title('Ground Truth (Target)');

subplot(1, 3, 2);
imshow(test_input);
title('Simple Reconstruction (Input)');

subplot(1, 3, 3);
imshow(test_output);
title('CNN Enhanced Output');
colormap gray;