function reconstructedImg = simpleReconstruction(dataMatrix, res)
% SIMPLERECONSTRUCTION Builds an image by summing weighted Walsh masks.
%
% Inputs:
%   dataMatrix - N x 2 matrix [mask_index, adc_value]
%   res        - Resolution array, e.g., [64, 64]
%
% Outputs:
%   reconstructedImg - The normalized 2D image matrix

    W = res(1); 
    H = res(2);
    
    % 1. Extract indices and raw ADC values
    indices = dataMatrix(:, 1);
    raw_adc_values = dataMatrix(:, 2);
    
    % 2. Remove the DC Baseline (Crucial for physical simulation)
    % This isolates the tiny high-frequency structural variations (+/- 20 counts)
    % from the massive ambient light baseline (~2000 counts).
    mean_val = mean(raw_adc_values);
    ac_values = raw_adc_values - mean_val;
    
    % 3. Initialize a blank canvas
    reconstructedImg = zeros(H, W);
    
    fprintf('Reconstructing %dx%d image using %d masks...\n', W, H, length(indices));
    
    % 4. Back-Projection Loop
    for i = 1:length(indices)
        idx = indices(i);
        weight = ac_values(i);
        
        % Generate the IDEAL mathematical mask for reconstruction
        % Note: We use the perfect +1/-1 math basis here, NOT the physical 
        % 0.9/0.08 constraints we used for the optical capture simulation.
        mask = double(generate_walsh_mask(idx, res));
        
        % Multiply the mask by its AC weight and add it to the total image
        reconstructedImg = reconstructedImg + (weight * mask);
    end
    
    % 5. Normalize the final image for display (scale from 0 to 1)
    reconstructedImg = reconstructedImg - min(reconstructedImg(:));
    reconstructedImg = reconstructedImg / max(reconstructedImg(:));
    
    % --- Display the Result ---
    figure('Name', 'Simple Linear Reconstruction', 'Position', [300, 300, 500, 500]);
    imshow(reconstructedImg);
    title(sprintf('Reconstructed (Sampled %d / %d)', length(indices), W*H));
    colormap gray;
end