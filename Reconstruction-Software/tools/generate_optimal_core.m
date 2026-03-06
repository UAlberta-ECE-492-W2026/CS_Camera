%==========================================================================
% SCRIPT: generate_optimal_core.m
% PURPOSE: Finds the 128 lowest-frequency Walsh-Hadamard indices
%==========================================================================

W = 64; H = 64;
total_masks = W * H;

% 1. Create array of all indices (0 to 4095)
indices = 0:(total_masks-1);

% 2. Calculate their X and Y frequencies
seq_x = mod(indices, W);
seq_y = floor(indices / W);

% 3. Calculate True Spatial Frequency
true_freq = seq_x + seq_y;

% 4. Sort by true frequency (lowest to highest)
% 'sorted_order' tells us the positions of the sorted elements
[~, sorted_order] = sort(true_freq);

% 5. Extract the first 256 indices (the lowest frequencies)
optimal_128_indices = indices(sorted_order(1:256));

% 6. Print the result formatted for C++
fprintf('const uint16_t optimal_core[256] = {\n    ');
for i = 1:256
    fprintf('%d', optimal_128_indices(i));
    if i < 256
        fprintf(', ');
    end
    if mod(i, 16) == 0 && i < 256 % Line break every 16 numbers
        fprintf('\n    ');
    end
end
fprintf('\n};\n');