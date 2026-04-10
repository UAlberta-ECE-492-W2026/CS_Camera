%==========================================================================
% SCRIPT_NAME:  export_optimal_indices.m
%
% PURPOSE:      Generates optimal core indices based on grid resolution 
%               and exports them to a formatted C++ array for hardware 
%               implementation.
%
% AUTHOR:       Cole Mckay (cdmckay1@ualberta.ca)
% DATE:         April 10, 2026
% VERSION:      1.0
%
% NOTES:        Outputs a text file (optimal_indices.txt) containing a 
%               C++ constant integer array (optimalCoreIndices). Designed 
%               to bridge MATLAB index calculations with the microcontroller 
%               firmware (e.g., Raspberry Pi Pico 2 / ESP32).
%==========================================================================

% --- Configuration ---
res = [64, 64];           % Grid resolution
numBase = 256;            % Number of indices to extract
outputFileName = 'optimal_indices.txt';
arrayName = 'optimalCoreIndices';

% --- Call the function ---
optimalIndices = utils.getOptimalCore(res, numBase);

% --- Write to File ---
fid = fopen(outputFileName, 'w');
if fid == -1
    error('Could not create the file. Check folder permissions.');
end

% Write the header
fprintf(fid, 'const int %s[%d] = {\n    ', arrayName, length(optimalIndices));

% Write the indices with a newline every 12 elements for readability
for i = 1:length(optimalIndices)
    if i == length(optimalIndices)
        fprintf(fid, '%d', optimalIndices(i)); % Last element, no comma
    else
        fprintf(fid, '%d, ', optimalIndices(i));
    end
    
    % Add a newline every 12 elements
    if mod(i, 12) == 0 && i ~= length(optimalIndices)
        fprintf(fid, '\n    ');
    end
end

% Close the array and file
fprintf(fid, '\n};');
fclose(fid);
fprintf('Success! C++ array saved to %s\n', outputFileName);