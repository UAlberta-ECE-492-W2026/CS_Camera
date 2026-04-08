function optimalIndices = getOptimalCore(res, numBase)
% GETOPTIMALCORE Identifies low-frequency Walsh mask indices based on Manhattan distance.
%
% Inputs:
%   res      - Resolution of the mask grid [width, height]
%   numBase  - Number of low-frequency indices to return
%
% Outputs:
%   optimalIndices - Array of mask indices sorted by spatial frequency

%==========================================================================
% AUTHOR:        Cole Mckay (cdmckay1@ualberta.ca)
% DATE:          April 7, 2026
% VERSION:       1.0
%==========================================================================
    
    W = res(1);
    H = res(2);
    total_masks = W * H;
    indices = 0:(total_masks-1);

    % Calculate X and Y frequencies based on the provided resolution
    seq_x = mod(indices, W);
    seq_y = floor(indices / W);

    % Calculate Spatial Frequency
    true_freq = seq_x + seq_y;

    % Sort and extract the specified number of base indices
    [~, sorted_order] = sort(true_freq);
    optimalIndices = indices(sorted_order(1:numBase));
end