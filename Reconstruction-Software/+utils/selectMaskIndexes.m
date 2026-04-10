function selectedIndexes = selectMaskIndexes(initialIndices, samplingPercentage, res)
% SELECTMASKINDEXES Samples additional random indices to reach a target sampling density.
%
% Inputs:
%   initialIndices     - Array of base/optimal mask indices to include
%   samplingPercentage - Target density (expressed as a fraction, e.g., 0.1 for 10%)
%   res                - Resolution of the mask grid [width, height]
%
% Outputs:
%   selectedIndexes    - Combined and sorted array of mask indices

%==========================================================================
% AUTHOR:        Cole Mckay (cdmckay1@ualberta.ca)
% DATE:          April 7, 2026
% VERSION:       1.0
%==========================================================================
    
    W = res(1);
    H = res(2);
    totalMasks = W * H;
    numToSample = round(samplingPercentage * totalMasks);
    
    if numToSample < length(initialIndices)
        warning('Sampling percentage is lower than the base set. Returning base set.');
        selectedIndexes = initialIndices;
        return;
    end
    
    % Pool of all possible mask indexes for this resolution
    allIndexes = 0:(totalMasks-1);
    
    % Remove the "must-have" indices from the random pool
    remainingPool = setdiff(allIndexes, initialIndices);
    
    % Determine how many random high-frequency masks to add
    additionalNeeded = numToSample - length(initialIndices);
    
    % Randomly sample from the remaining pool
    randomPicker = randperm(length(remainingPool));
    extraSelection = remainingPool(randomPicker(1:additionalNeeded));
    
    % Combine and sort
    selectedIndexes = sort([initialIndices(:); extraSelection(:)]);
end