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
%   dataMatrix - An N x 2 matrix where the first column is the mask index 
%                and the second column is the rounded, averaged noisy signal.

    % Flatten the image into a 1D column vector and ensure double precision
    flatIMG = double(img(:));
    
    % --- Extract Hardware & Gain Parameters ---
    % If sensor_gain isn't in your JSON yet, default to the 5x multiplier
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
    
    % Initialize the output matrix
    numMasks = length(maskList);
    dataMatrix = zeros(numMasks, 2);
    
    for i = 1:numMasks
        index = maskList(i);
        
        % Generate and apply constraints to the mask
        mask = double(generate_walsh_mask(index, cfg.sampling_parameters.resolution));
        
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
        % Ensures the amplified signal doesn't exceed the Pi's ADC max (e.g., 3800)
        finalSignal = min(max(avgSignal, 0), satLimit);
        
        % Store the result
        dataMatrix(i, :) = [index, round(finalSignal)];
    end
end