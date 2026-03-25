function reconstructedImg = simpleReconstruction(dataMatrix)
% SIMPLERECONSTRUCTION Builds an image by summing weighted Walsh masks.
%
% Inputs:
%   dataMatrix - N x 2 matrix [mask_index, adc_value]. Must contain a 
%                header row with index -1 defining the square resolution.
%
% Outputs:
%   reconstructedImg - The normalized 2D image matrix

    % 1. Extract resolution from the header row (index == -1)
    resRowIdx = find(dataMatrix(:, 1) == -1);
    
    if isempty(resRowIdx)
        error('Resolution metadata not found. Missing -1 index in dataMatrix.');
    end
    
    % Since it is a square, W and H are the same value
    resValue = dataMatrix(resRowIdx, 2);
    W = resValue; 
    H = resValue;
    res = [W, H]; % Rebuild the array for generate_walsh_mask
    
    % Remove the resolution metadata row from the matrix before processing
    dataMatrix(resRowIdx, :) = [];
    
    % 2. Extract indices and raw ADC values from the remaining data
    indices = dataMatrix(:, 1);
    raw_adc_values = dataMatrix(:, 2);
    
    % 3. Remove the DC Baseline 
    mean_val = mean(raw_adc_values);
    ac_values = raw_adc_values - mean_val;
    
    % 4. Initialize a blank canvas
    reconstructedImg = zeros(H, W);
    
    fprintf('Reconstructing %dx%d image using %d masks...\n', W, H, length(indices));
    
    % 5. Back-Projection Loop
    for i = 1:length(indices)
        idx = indices(i);
        weight = ac_values(i);
        
        % Generate the IDEAL mathematical mask for reconstruction
        mask = double(utils.generate_walsh_mask(idx, res));
        
        % Multiply the mask by its AC weight and add it to the total image
        reconstructedImg = reconstructedImg + (weight * mask);
    end
    
    % 6. Normalize the final image for display (scale from 0 to 1)
    reconstructedImg = reconstructedImg - min(reconstructedImg(:));
    reconstructedImg = reconstructedImg / max(reconstructedImg(:));
    
    % % --- Display the Result ---
    % figure('Name', 'Simple Linear Reconstruction', 'Position', [300, 300, 500, 500]);
    % imshow(reconstructedImg);
    % title(sprintf('Reconstructed (Sampled %d / %d)', length(indices), W*H));
    % colormap gray;
end