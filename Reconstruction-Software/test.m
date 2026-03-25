% 1. Define File and Parameters
csvFile = 'sensor_data.csv'; % Replace with your actual filename
res = [64, 64];

% 2. Load the CSV into a matrix
% readmatrix automatically handles numeric data and marks blanks as NaN
dataMatrix = readmatrix(csvFile);

% 3. Data Cleaning
% A. Remove rows where any entry is blank (NaN)
dataMatrix(any(isnan(dataMatrix), 2), :) = [];

% B. Remove rows where the first column (A) equals -1
% Logic: Find rows where column 1 is -1 and delete them
dataMatrix(dataMatrix(:, 1) == -1, :) = [];

% 4. Call the Reconstruction Function
% Ensure simpleReconstruction.m is in your current folder or path
reconstructedImg = reco.simpleReconstruction(dataMatrix, res);

% 5. (Optional) Visualize the result
figure;
imagesc(reconstructedImg);
colormap gray;
axis image;
title('Reconstructed Image');