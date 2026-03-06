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
cfg = load_config('camera_settings.json');

% Load Scene
img = imread('cameraman.tif');
img = imresize(img, cfg.sampling_parameters.resolution);
img = double(img);

% Quick Check Script
indices_to_test = [0, 1, 63, 3*512];
titles = {'Index 0 (DC)', 'Index 1', 'Index 63', 'Index 1536'};

figure('Name', 'Walsh-Hadamard Verification');
for i = 1:4
    subplot(2, 2, i);
    mask = generate_walsh_mask(indices_to_test(i), cfg.sampling_parameters.resolution);
    imagesc(mask); 
    colormap gray; 
    axis image;
    title(titles{i});
end