function [config] = loadConfig(filename)
% LOADCONFIG Loads and decodes a JSON configuration file.
%
% Inputs:
%   filename - Name of the JSON file, or absolute path to the JSON file.
%
% Outputs:
%   config   - Struct containing the decoded JSON data

%==========================================================================
% AUTHOR:        Cole Mckay (cdmckay1@ualberta.ca)
% DATE:          April 7, 2026
% VERSION:       1.1
%==========================================================================
    
arguments (Input)
        filename {mustBeText}
    end
    
    arguments (Output)
        config struct
    end
    
    % Check if the provided filename is already a valid complete path
    if isfile(filename)
        full_path = filename;
    else
        % If not, assume it's just the filename and check the local configs folder
        config_folder = 'configs';
        full_path = fullfile(config_folder, filename);
    end
    
    % Final check before trying to read
    if ~isfile(full_path)
        error('File Not Found: Could not locate the configuration file at "%s".', full_path);
    end
    
    % Read and Decode
    try
        raw_text = fileread(full_path);
        config = jsondecode(raw_text);
    catch ME
        error('Error processing JSON: %s', ME.message);
    end
end