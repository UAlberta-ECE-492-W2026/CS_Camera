function reconstructedImg = tvReconstruction(dataMatrix)
% TVRECONSTRUCTION Builds an image using Edge-Preserving Total Variation minimization.
%
% Inputs:
%   dataMatrix - N x 2 matrix [mask_index, adc_value]. Must contain a 
%                header row with index -1 defining the square resolution.
%
% Outputs:
%   reconstructedImg - The normalized 2D image matrix
%==========================================================================
% AUTHOR:        Cole Mckay (cdmckay1@ualberta.ca)
% DATE:          April 7, 2026
% VERSION:       1.0
%==========================================================================

    % 1. Parse resolution metadata
    resRowIdx = find(dataMatrix(:, 1) == -1);
    if isempty(resRowIdx)
        error('Resolution metadata not found. Missing -1 index in dataMatrix.');
    end
    
    resValue = dataMatrix(resRowIdx, 2);
    W = resValue; 
    H = resValue;
    res = [W, H];
    numPixels = W * H;
    
    dataMatrix(resRowIdx, :) = [];
    
    % 2. Extract measurements and remove DC offset
    indices = dataMatrix(:, 1);
    raw_adc_values = dataMatrix(:, 2);
    y = raw_adc_values - mean(raw_adc_values);
    numMasks = length(indices);
    
    fprintf('Starting Edge-Preserving TV Reconstruction for %dx%d image...\n', W, H);
    
    % 3. Build Sensing Matrix (Phi)
    Phi = zeros(numMasks, numPixels);
    for i = 1:numMasks
        mask = double(utils.generateWalshMask(indices(i), res));
        Phi(i, :) = mask(:)';
    end
    
    % 4. Solver Hyperparameters
    lambda = 50;                
    alpha = 1.9 / norm(Phi)^2;  
    max_iter = 300;             
    epsilon = 1e-5;             
    sigma = max(abs(y)) * 0.25; % Edge-stopping threshold
    
    % Linear back-projection for initial state
    x = Phi' * y;
    
    fprintf('Optimizing (iter: %d, sigma: %.3f)...\n', max_iter, sigma);
    
    % 5. Optimization Loop
    for iter = 1:max_iter
        X_img = reshape(x, [H, W]);
        
        % Spatial gradients
        Dx = [diff(X_img, 1, 2), zeros(H, 1)];
        Dy = [diff(X_img, 1, 1); zeros(1, W)];
        
        edge_mag = sqrt(Dx.^2 + Dy.^2);
        
        % Perona-Malik weight matrix
        W_edges = 1 ./ (1 + (edge_mag / sigma).^2);
        
        % Normalized and weighted gradients
        norm_grad = sqrt(Dx.^2 + Dy.^2 + epsilon);
        weighted_grad_x = W_edges .* (Dx ./ norm_grad);
        weighted_grad_y = W_edges .* (Dy ./ norm_grad);
        
        % Divergence (adjoint of weighted gradient)
        div_x = [weighted_grad_x(:, 1), diff(weighted_grad_x, 1, 2)];
        div_y = [weighted_grad_y(1, :); diff(weighted_grad_y, 1, 1)];
        tv_grad_flat = reshape(-(div_x + div_y), [], 1);
        
        % Data fidelity gradient update
        data_grad = Phi' * (Phi * x - y);
        x = x - alpha * (data_grad + lambda * tv_grad_flat);
        
        if mod(iter, 50) == 0
            fprintf('Iteration %d / %d completed.\n', iter, max_iter);
        end
    end
    
    % 6. Output normalization
    reconstructedImg = reshape(x, [H, W]);
    reconstructedImg = (reconstructedImg - min(reconstructedImg(:))) / ...
                       (max(reconstructedImg(:)) - min(reconstructedImg(:)));
end