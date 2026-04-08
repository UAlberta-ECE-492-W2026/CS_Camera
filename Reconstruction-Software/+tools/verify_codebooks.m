%==========================================================================
% SCRIPT_NAME: verify_codebooks.m
% PURPOSE:     Generates the MATLAB codebook and compares it against the 
%              C++ generated binary file to ensure 1:1 mathematical parity.
%==========================================================================

clear;

H = 64; 
W = 64;
total_masks = H * W;

disp('1. Generating MATLAB Codebook...');
matlab_codebook = zeros(H, W, total_masks, 'uint8');
for i = 0:(total_masks - 1)
    % Call your self-documenting function
    % Convert logical output to uint8 for direct comparison
    matlab_codebook(:,:,i+1) = uint8(generateWalshMask(i, [H, W]));
end

disp('2. Loading C++ Codebook...');
fileID = fopen('cpp_codebook.bin', 'r');
if fileID == -1
    error('Could not open cpp_codebook.bin. Did you run the C++ script?');
end
% Read the raw 16MB file into a 1D vector
cpp_raw = fread(fileID, H * W * total_masks, '*uint8');
fclose(fileID);

disp('3. Aligning Memory (Row-Major to Column-Major)...');
% Reshape into 3D array (Width, Height, Masks) because C++ wrote rows first
cpp_reshaped = reshape(cpp_raw, [W, H, total_masks]);
% Swap the X and Y axes to match MATLAB's (Height, Width, Masks) format
cpp_codebook = permute(cpp_reshaped, [2, 1, 3]);

disp('4. Comparing Codebooks...');
is_exact_match = isequal(matlab_codebook, cpp_codebook);

if is_exact_match
    fprintf('\n========================================\n');
    fprintf('SUCCESS: Codebooks are a 100%% EXACT match!\n');
    fprintf('========================================\n');
else
    fprintf('\nERROR: Codebooks do not match.\n');
    diff_sum = sum(matlab_codebook(:) ~= cpp_codebook(:));
    fprintf('Number of mismatched pixels: %d\n', diff_sum);
end