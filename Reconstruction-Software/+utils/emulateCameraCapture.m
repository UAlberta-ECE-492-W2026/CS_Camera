function [camera_data, ground_truth] = emulateCameraCapture(imgInput, cfg, maskList)
% EMULATECAMERACAPTURE Simulates capturing an image with a compressive sensing camera.
%
% Inputs:
%   imgInput - Image matrix or filepath string
%   cfg      - Struct containing camera and sampling configurations
%   maskList - List of Walsh-Hadamard masks used for capture
%
% Outputs:
%   camera_data  - Simulated ADC capture values
%   ground_truth - The cropped, resized, and normalized reference image

%==========================================================================
% AUTHOR:        Cole Mckay (cdmckay1@ualberta.ca)
% DATE:          April 7, 2026
% VERSION:       1.0
%==========================================================================

    % 1. Handle both filepaths and raw image matrices
    if ischar(imgInput) || isstring(imgInput)
        rawImg = imread(imgInput);
    else
        rawImg = imgInput;
    end

    if size(rawImg, 3) == 3
        rawImg = im2gray(rawImg);
    end

    target_res = cfg.sampling_parameters.resolution;
    
    % Get current image dimensions
    [rows, cols, ~] = size(rawImg);
    
    % Crop the raw image to a square

    shortest_side = min(rows, cols);
    win = centerCropWindow2d([rows, cols], [shortest_side, shortest_side]);
    croppedImg = imcrop(rawImg, win);
    ground_truth = imresize(im2double(croppedImg), target_res);

    % 5. Simulation of capture
    camera_data = utils.simulateCapture(ground_truth, maskList, cfg);
    
end