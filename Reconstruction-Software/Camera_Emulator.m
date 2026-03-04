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

% Initialize camera parameters
cfg = load_config('camera_settings.json');

% Load Scene
img = imread('cameraman.tif');
img = imresize(img, cfg.sampling_parameters.resolution);
img = double(img);

% Generate Walsh-Hadamard Codebook