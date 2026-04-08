function reconstructedImg = cnnReconstruction(dataMatrix)
% CNNRECONSTRUCTION Reconstructs an image and enhances it using a trained CNN.
%
% Inputs:
%   dataMatrix - N x 2 matrix [mask_index, adc_value]. Must contain a 
%                header row with index -1 defining the square resolution.
%
% Outputs:
%   reconstructedImg - The CNN-enhanced normalized 2D image matrix

%==========================================================================
% AUTHOR:        Cole Mckay (cdmckay1@ualberta.ca)
% DATE:          April 7, 2026
% VERSION:       1.0
%==========================================================================

    persistent net;
    
    % Load the model only if it is not loaded already.
    if isempty(net)
        try
            modelPath = fullfile('+models', 'cs_enhancement_net_ResNet.mat');
            modelData = load(modelPath, 'net');
            net = modelData.net;
        catch ME
            error('Could not load CNN model. Ensure it is located at %s.\n%s', modelPath, ME.message);
        end
    end
    
    % 1. Generate the base image using simple reconstruction
    baseImg = reco.simpleReconstruction(dataMatrix);
    
    % 2. Enhance the simple reconstruction using the CNN
    cnn_enhanced = predict(net, baseImg);
    
    % 3. Normalize the final CNN output for display
    reconstructedImg = double(cnn_enhanced); 
    reconstructedImg = reconstructedImg - min(reconstructedImg(:));
    reconstructedImg = reconstructedImg / max(reconstructedImg(:));
    
end