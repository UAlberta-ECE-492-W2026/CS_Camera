function reconstructedImg = tvReconstruction(dataMatrix)
% TVRECONSTRUCTION Builds an image using Total Variation (TV) minimization.
%
% Inputs:
%   dataMatrix - N x 2 matrix [mask_index, adc_value]. Must contain a 
%                header row with index -1 defining the square resolution.
%
% Outputs:
%   reconstructedImg - The normalized 2D image matrix

    % 1. Extract resolution from the header row
    resRowIdx = find(dataMatrix(:, 1) == -1);
    
    if isempty(resRowIdx)
        error('Resolution metadata not found. Missing -1 index in dataMatrix.');
    end
    
    resValue = dataMatrix(resRowIdx, 2);
    W = resValue; 
    H = resValue;
    res = [W, H];
    numPixels = W * H;
    
    % Remove the resolution metadata row
    dataMatrix(resRowIdx, :) = [];
    
    % 2. Extract indices and measurements
    indices = dataMatrix(:, 1);
    raw_adc_values = dataMatrix(:, 2);
    
    % Remove DC Baseline
    mean_val = mean(raw_adc_values);
    y = raw_adc_values - mean_val;
    numMasks = length(indices);
    
    fprintf('Starting TV Reconstruction for %dx%d image...\n', W, H);
    fprintf('Building measurement matrix (this may take a moment)...\n');
    
    % 3. Build the Sensing Matrix (Phi)
    % Each row of Phi represents one flattened Walsh mask
    Phi = zeros(numMasks, numPixels);
    for i = 1:numMasks
        mask = double(utils.generate_walsh_mask(indices(i), res));
        Phi(i, :) = mask(:)';
    end
    
    % 4. TV Minimization Setup (Gradient Descent)
    % --- HYPERPARAMETERS ---
    lambda = 50;           % TV regularization weight (increase for smoother image)
    alpha = 2*1 / norm(Phi)^2; % Step size (prevents the math from exploding)
    max_iter = 300;          % Number of iterations to refine the image
    epsilon = 1e-5;          % Smoothing term to prevent division by zero in gradients
    
    % Initialize the starting guess using standard linear back-projection
    x = Phi' * y;
    
    fprintf('Optimizing over %d iterations...\n', max_iter);
    
    % 5. Optimization Loop
    for iter = 1:max_iter
        % Reshape current estimate back to a 2D image
        X_img = reshape(x, [H, W]);
        
        % Calculate spatial gradients (differences between neighboring pixels)
        Dx = [diff(X_img, 1, 2), zeros(H, 1)]; % Horizontal derivative
        Dy = [diff(X_img, 1, 1); zeros(1, W)]; % Vertical derivative
        
        % Gradient of the TV norm
        norm_grad = sqrt(Dx.^2 + Dy.^2 + epsilon);
        grad_x = Dx ./ norm_grad;
        grad_y = Dy ./ norm_grad;
        
        % Divergence (adjoint of the gradient)
        div_x = [grad_x(:, 1), diff(grad_x, 1, 2)];
        div_y = [grad_y(1, :); diff(grad_y, 1, 1)];
        tv_grad = -(div_x + div_y);
        
        % Flatten the TV gradient back to a 1D column
        tv_grad_flat = tv_grad(:);
        
        % Calculate data fidelity gradient (how far off are we from the real measurements?)
        data_grad = Phi' * (Phi * x - y);
        
        % Update step: move against the gradient
        x = x - alpha * (data_grad + lambda * tv_grad_flat);
        
        % Print progress
        if mod(iter, 20) == 0
            fprintf('Iteration %d / %d completed.\n', iter, max_iter);
        end
    end
    
    % 6. Reshape and Normalize the final output
    reconstructedImg = reshape(x, [H, W]);
    reconstructedImg = reconstructedImg - min(reconstructedImg(:));
    reconstructedImg = reconstructedImg / max(reconstructedImg(:));
    
    % % --- Display the Result ---
    % figure('Name', 'Total Variation Reconstruction', 'Position', [850, 300, 500, 500]);
    % imshow(reconstructedImg);
    % title(sprintf('TV Reconstructed (Sampled %d / %d)', numMasks, numPixels));
    % colormap gray;
end