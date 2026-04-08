% =========================================================================
% SCRIPT_NAME: test_emulateCameraCapture.m
% PURPOSE:     Tests the emulateCameraCapture function to ensure it crops,
%              resizes, and simulates the capture correctly.
% =========================================================================
clear; clc; close all;

fprintf('--- Starting Test --- \n');

% 1. Setup global parameters (using your existing namespace functions)
fprintf('Loading configuration and masks...\n');
cfg = utils.loadConfig('camera_settings.json');
maskList = utils.selectMaskIndexes(utils.getOptimalCore(cfg.sampling_parameters.resolution, ...
    cfg.sampling_parameters.core_mask_count), cfg.sampling_parameters.sampling_pct, ...
    cfg.sampling_parameters.resolution);

% 2. Define a test image
% Using MATLAB's built-in image so it runs instantly
testImagePath = 'images/3096.jpg'; 

% 3. Call the function
fprintf('Running emulateCameraCapture on %s...\n', testImagePath);
[camera_data, ground_truth] = utils.emulateCameraCapture(testImagePath, cfg, maskList);

% 4. Verify the outputs
fprintf('\n--- Test Results ---\n');

% Check Ground Truth
[h, w, c] = size(ground_truth);
fprintf('Ground Truth Size: %d x %d x %d (Should be a perfect square and 1 channel)\n', h, w, c);
fprintf('Ground Truth Range: Min = %.2f, Max = %.2f (Should be 0.0 to 1.0)\n', ...
    min(ground_truth(:)), max(ground_truth(:)));

% Check Camera Data
[numMeasurements, cols] = size(camera_data);
fprintf('Camera Data Size: %d rows x %d cols (Should be N x 2)\n', numMeasurements, cols);

% 5. Visual Verification
figure('Name', 'emulateCameraCapture Test', 'Position', [100, 100, 800, 400]);

% Plot Ground Truth Image
subplot(1, 2, 1);
imshow(ground_truth);
title(sprintf('Ground Truth Target\n(%dx%d Square Crop)', h, w));

subplot(1, 2, 2);
final_image = reco.simpleReconstruction(camera_data);
imshow(final_image);
title('Simple Linear Reconstruction');
colormap gray;

fprintf('\nTest complete! Check the figure to visually verify the square crop.\n');