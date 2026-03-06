%==========================================================================
% SCRIPT_NAME: Camera_Emulator.m
% PURPOSE:     Simulates capturing an image with the compressive sensing 
%              camera.
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
%==========================================================================\

clear;

% Initialize camera parameters
cfg = loadConfig('camera_settings.json');

% Load, resize, and normalize to a 0.0 - 1.0 scale
img = imresize(im2double(imread('cameraman.tif')), cfg.sampling_parameters.resolution);

% Sampling Strategy (Mask Selection)

maskList = selectMaskIndexes(getOptimalCore(cfg.sampling_parameters.resolution, ...
    cfg.sampling_parameters.core_mask_count), cfg.sampling_parameters.sampling_pct, ...
    cfg.sampling_parameters.resolution);
