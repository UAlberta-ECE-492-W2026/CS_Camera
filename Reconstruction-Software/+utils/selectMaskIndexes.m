function selectedIndexes = selectMaskIndexes(initialIndices, samplingPercentage, res)
    % initialIndices: The array from getOptimalCore
    % samplingPercentage: 0 to 100
    % res: The resolution of the mask (e.g., 64)
    
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