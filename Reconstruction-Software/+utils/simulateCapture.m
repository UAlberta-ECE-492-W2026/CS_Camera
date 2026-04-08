function dataMatrix = simulateCapture(img, maskList, cfg)
% SIMULATECAPTURE Simulates the capture process using Walsh masks.
%
% Inputs:
%   img      - The input image matrix to be captured.
%   maskList - A vector containing the indices of the masks to apply.
%   cfg      - A configuration structure containing sampling_parameters, 
%              mask_constraints, hardware limits, and sensor_noise.
%
% Outputs:
%   dataMatrix - An (N+1) x 2 matrix. Row 1 contains the resolution metadata 
%                (index -1), and the rest contain [mask_index, adc_value].

%==========================================================================
% AUTHOR:        Cole Mckay (cdmckay1@ualberta.ca)
% DATE:          April 7, 2026
% VERSION:       1.0
%==========================================================================

    % Flatten the image into a 1D column vector and ensure double precision
    flatIMG = double(img(:));
    
    % --- Extract Hardware & Gain Parameters ---
    if isfield(cfg.hardware, 'sensor_gain')
        sensorGain = cfg.hardware.sensor_gain;
    else
        sensorGain = 1.5; 
    end
    
    satLimit = cfg.hardware.saturation_limit;
    darkCurrent = cfg.sensor_noise.dark_current_counts;
    baseStdDev = cfg.sensor_noise.std_dev_counts;
    
    % Noise scales roughly with the square root of the gain increase
    effectiveStdDev = baseStdDev * sqrt(sensorGain);
    
    numMasks = length(maskList);
    
    % Initialize the output matrix with an extra row for the resolution header
    dataMatrix = zeros(numMasks + 1, 2);
    
    % Store the resolution in the first row. 
    % Taking the first element since the image is always square.
    dataMatrix(1, :) = [-1, cfg.sampling_parameters.resolution(1)];
    
    for i = 1:numMasks
        index = maskList(i);
        
        % Generate and apply constraints to the mask
        mask = double(utils.generateWalshMask(index, cfg.sampling_parameters.resolution));
        
        physMask = mask;
        physMask(mask == 1) = cfg.mask_constraints.white_attenuation_pct;
        physMask(mask == -1 | mask == 0) = cfg.mask_constraints.black_leakage_pct;
        physMask = physMask(:);
        
        % Calculate the raw optical signal via dot product
        rawOpticalSignal = dot(flatIMG, physMask);
        
        % --- APPLY HARDWARE GAIN ---
        amplifiedSignal = rawOpticalSignal * sensorGain;
        
        % Add dark current and scaled noise
        noiseSamples = amplifiedSignal + darkCurrent + (effectiveStdDev ... 
            * randn(cfg.sampling_parameters.samples_per_mask, 1));
        
        % Average the samples
        avgSignal = mean(noiseSamples);
        
        % --- APPLY ADC HARDWARE LIMITS (CLIPPING) ---
        finalSignal = min(max(avgSignal, 0), satLimit);
        
        % Store the result (shifted by 1 to protect the resolution header)
        dataMatrix(i + 1, :) = [index, round(finalSignal)];
    end
end