%==========================================================================
% SCRIPT_NAME:  generate_training_data.m
%
% PURPOSE:      Batch processes Tiny ImageNet to simulate compressive 
%               sensing captures for CNN training.
%
% AUTHOR:       Cole Mckay (cdmckay1@ualberta.ca)
% DATE:         April 7, 2026
% VERSION:      1.2
%
% NOTES:        Requires Parallel Computing Toolbox. Ensure the 
%               'tiny-imagenet-200' folder is in the root /images/ directory.
%==========================================================================
clear; clc;

fprintf('Loading configuration and masks...\n');
% Load configuration and calculate masks using your existing utilities
cfg = utils.loadConfig('camera_settings.json');

fprintf('Starting parallel pool...\n');
% 1. Detect the total number of logical cores using the Java environment
numLogicalCores = java.lang.Runtime.getRuntime().availableProcessors();
% 2. Calculate n-1 workers, ensuring we never request fewer than 1 worker
numWorkers = max(1, numLogicalCores - 1);
fprintf('Detected %d logical cores. Configuring pool for %d workers...\n', numLogicalCores, numWorkers);

% 3. Override MATLAB's default worker limits for the local profile
localCluster = parcluster('local');
if localCluster.NumWorkers < numWorkers
    localCluster.NumWorkers = numWorkers;
end

% 4. Start the pool using the updated cluster profile and worker count
if isempty(gcp('nocreate'))
    parpool(localCluster, numWorkers); 
end

maskList = utils.selectMaskIndexes(utils.getOptimalCore(cfg.sampling_parameters.resolution, ...
    cfg.sampling_parameters.core_mask_count), cfg.sampling_parameters.sampling_pct, ...
    cfg.sampling_parameters.resolution);

% Set the path to the dataset
% 1. Get the folder where this script is currently saved (e.g., +tools)
scriptDir = fileparts(mfilename('fullpath'));

% 2. Navigate up one level to the project root
rootDir = fileparts(scriptDir);

% 3. Build a portable path to the dataset from the root
datasetPath = fullfile(rootDir, 'images', 'tiny-imagenet-200', 'train');
fprintf('Checking image datastore at %s...\n', datasetPath);
imds = imageDatastore(datasetPath, 'IncludeSubfolders', true);
numImages = length(imds.Files);

if numImages == 0
    error('No images found. Please verify the datasetPath is correct and accessible.');
end

% Pre-allocate arrays to hold the training data
% Format needed for MATLAB CNNs: [Height, Width, Channels, NumImages]
res = cfg.sampling_parameters.resolution(1); 
numMasks = length(maskList);

% X_train holds the 1D raw measurements
X_train_raw = zeros(numMasks, 1, 1, numImages); 
% Y_train holds the perfectly cropped and scaled target images
Y_train = zeros(res, res, 1, numImages);

fprintf('Processing %d images...\n', numImages);

% Process the dataset
fprintf('Processing %d images across multiple CPU cores...\n', numImages);

% 1. Create the Data Queue
dq = parallel.pool.DataQueue;

% 2. Attach a listener that triggers our custom print function
afterEach(dq, @(~) printCmdLineProgress(numImages));

% 3. The Parallel Loop
parfor i = 1:numImages
    % Read image from the datastore
    rawImg = readimage(imds, i);
    
    % Pass through your emulator function
    [camera_data, ground_truth] = utils.emulateCameraCapture(rawImg, cfg, maskList);
    
    % Store the results
    X_train_raw(:, 1, 1, i) = camera_data(2:end, 2); 
    Y_train(:, :, 1, i) = ground_truth;
    
    % Send a blank signal to the queue indicating this iteration is done
    send(dq, []);
end

fprintf('Parallel processing complete!\n');

% Save the final workspace variables to disk
dataDir = fullfile(rootDir, 'data');
if ~exist(dataDir, 'dir')
    mkdir(dataDir);
end

outputFileName = fullfile(dataDir, 'cnn_training_data_50p.mat');
save(outputFileName, 'X_train_raw', 'Y_train', 'maskList', '-v7.3'); % -v7.3 flag handles large files
fprintf('\nDataset generated successfully! Saved to: %s\n', outputFileName);

% =========================================================================
% LOCAL FUNCTIONS
% =========================================================================

function printCmdLineProgress(totalImages)
    % Manages shared state for progress tracking across asynchronous parfor workers
    persistent count startTime reverseStr;
    
    if isempty(count)
        count = 1;
        startTime = tic;
        reverseStr = '';
        fprintf('\n--- Starting Parallel Processing ---\n');
    else
        count = count + 1;
    end
    
    % Update interval set to 100 to reduce console I/O frequency
    if mod(count, 100) == 0 || count == totalImages
        
        pct = (count / totalImages) * 100;
        
        % Calculate throughput-based ETA
        elapsedTime = toc(startTime);
        imagesPerSec = count / elapsedTime;
        remainingImages = totalImages - count;
        etaSeconds = remainingImages / imagesPerSec;
        
        etaStr = char(duration(0, 0, etaSeconds, 'Format', 'hh:mm:ss'));
        
        % Overwrite previous line using backspace character buffering
        msg = sprintf('Processed: %d / %d (%.1f%%) | ETA: %s   ', count, totalImages, pct, etaStr);
        
        fprintf('%s', reverseStr);
        fprintf('%s', msg);
        
        reverseStr = repmat(sprintf('\b'), 1, length(msg));
    end
    
    if count == totalImages
        fprintf('\n'); 
        count = [];
        startTime = [];
        reverseStr = [];
    end
end