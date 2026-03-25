function optimalIndices = getOptimalCore(res, numBase)
    % res: The resolution of one side (e.g., 64 for a 64x64 grid)
    % numBase: The number of low-frequency masks to return (e.g., 256)
    
    W = res(1);
    H = res(2);
    total_masks = W * H;
    indices = 0:(total_masks-1);

    % Calculate X and Y frequencies based on the provided resolution
    seq_x = mod(indices, W);
    seq_y = floor(indices / W);

    % Calculate Spatial Frequency (Manhattan distance)
    true_freq = seq_x + seq_y;

    % Sort and extract the specified number of base indices
    [~, sorted_order] = sort(true_freq);
    optimalIndices = indices(sorted_order(1:numBase));
end