%==========================================================================
% SCRIPT_NAME: Camera_Emulator.m
%
% PURPOSE:     Simulates capturing an image with the compressive sensing 
%              camera.
%
% AUTHOR:      Cole Mckay (cdmckay1@ualberta.ca)
% DATE:        March 1, 2026
% VERSION:     0.0
%
% INPUTS:      
% OUTPUTS:     
%
% DEPENDENCIES: 
%==========================================================================
% REVISION HISTORY:
% 0.0 - Create File
%==========================================================================

clear;

% Initialize camera parameters
cfg = utils.loadConfig('camera_settings.json');

% Load, resize, and normalize to a 0.0 - 1.0 scale
img = imresize(im2double(im2gray(imread('penguin.tiff'))), cfg.sampling_parameters.resolution);
imshow('penguin.tiff');
% Sampling Strategy (Mask Selection)
maskList = utils.selectMaskIndexes(tools.getOptimalCore(cfg.sampling_parameters.resolution, ...
    cfg.sampling_parameters.core_mask_count), cfg.sampling_parameters.sampling_pct, ...
    cfg.sampling_parameters.resolution);

% Simulation of capture

camera_data = utils.simulateCapture(img, maskList, cfg);

final_image = reco.simpleReconstruction(camera_data);
tv_image = reco.tvReconstruction(camera_data);


outputFileName = 'camera_data_export.csv';
writematrix(camera_data, outputFileName);
disp(['Camera data successfully exported to: ', outputFileName]);