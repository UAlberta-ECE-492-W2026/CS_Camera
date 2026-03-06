%==========================================================================
% FUNCTION_NAME: load_config.m
% PURPOSE:       Load a JSON profile from /configs folder
% AUTHOR:        Cole Mckay (cdmckay1@ualberta.ca)
% DATE:          March 3, 2026
% VERSION:       1.0
%
% INPUTS:        filename - Name of the JSON file (e.g., 'sensor.json')
% OUTPUTS:       config   - MATLAB struct
%==========================================================================
% REVISION HISTORY:
% 0.0 - Create File
% 1.0 - Implemented fileread and jsondecode logic
%==========================================================================
function [config] = load_config(filename)
    
    arguments (Input)
        filename {mustBeText}
    end
    
    arguments (Output)
        config struct
    end

    % 1. Define the relative path to your configs folder
    config_folder = 'configs';
    
    % 2. Build the full path (handles / vs \ automatically)
    full_path = fullfile(config_folder, filename);

    % 3. Check if the file exists at that specific location
    if ~isfile(full_path)
        error('File Not Found: "%s" was not found in the /%s directory.', ...
              filename, config_folder);
    end

    % 4. Read and Decode
    try
        raw_text = fileread(full_path);
        config = jsondecode(raw_text);
    catch ME
        error('Error processing JSON: %s', ME.message);
    end

end