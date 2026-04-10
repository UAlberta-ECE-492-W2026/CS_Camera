%==========================================================================
% SCRIPT_NAME:  generate_optimal_core.m
%
% PURPOSE:      Calculates and extracts the 256 lowest-frequency 
%               Walsh-Hadamard indices based on true spatial frequency.
%
% AUTHOR:       Cole Mckay (cdmckay1@ualberta.ca)
% DATE:         April 10, 2026
% VERSION:      1.0
%
% NOTES:        Outputs a formatted C++ constant integer array containing 
%               the optimal core indices for direct copy-pasting into 
%               microcontroller firmware.
%==========================================================================

clear; clc;
W = 64; 
H = 64;
total_masks = W * H;

% 1. Create array of all indices (0 to 4095)
indices = 0:(total_masks-1);

% 2. Calculate X and Y frequencies
seq_x = mod(indices, W);
seq_y = floor(indices / W);

% 3. Calculate true spatial frequency
true_freq = seq_x + seq_y;

% 4. Sort by true frequency (lowest to highest)
[~, sorted_order] = sort(true_freq);

% 5. Extract the first 256 indices (lowest frequencies)
optimal_256_indices = indices(sorted_order(1:256));

% 6. Print the result formatted for C++
fprintf('const uint16_t optimal_core[256] = {\n    ');
for i = 1:256
    fprintf('%d', optimal_256_indices(i));
    
    if i < 256
        fprintf(', ');
    end
    
    % Line break every 16 numbers for readability
    if mod(i, 16) == 0 && i < 256 
        fprintf('\n    ');
    end
end
fprintf('\n};\n');