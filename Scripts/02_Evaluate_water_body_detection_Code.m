%% 02_Evaluate_water_body_detection.m
% Tutorial script for evaluating Sentinel-1-derived water body detection.
%
% In the associated study, two water body detection approaches were used:
% 1) K-means clustering
% 2) Otsu thresholding
%
% The full Sentinel-1 water body extraction workflow is not included in
% this tutorial. Instead, this script uses final preprocessed output files
% generated from each method and demonstrates how water body detection
% results can be evaluated using confusion matrix-based metrics.
%
% K-means workflow summary:
% - Sentinel-1 VH and VV backscatter images are clipped around each station.
% - The optimal number of clusters is determined using silhouette analysis.
% - K-means clustering is applied to classify SAR backscatter patterns.
% - Water-related pixels are identified and used to extract feature values.
%
% Otsu workflow summary:
% - Sentinel-1 VH and VV backscatter images are clipped around each station.
% - Automatic thresholding is applied to separate water and non-water pixels.
% - Water-related pixels are identified and summarized as feature values.
%
% This script is intended as a tutorial example, not the full
% project-specific implementation.

%% 1. Set data directory

dataDir = fullfile("..", "Data", "Sample_Data");

kmeansFile = fullfile(dataDir, ...
    "Sentinel1_Features_Sample_K_means_Clustering.xlsx");

otsuFile = fullfile(dataDir, ...
    "Sentinel1_Features_Sample_Otsu_Thresholding.xlsx");

%% 2. Load final preprocessed outputs

% These files are final preprocessed outputs generated from the K-means
% clustering and Otsu thresholding workflows.

kmeansOutput = readtable(kmeansFile);
otsuOutput = readtable(otsuFile);

disp("K-means final preprocessed output:");
disp(head(kmeansOutput));

disp("Otsu final preprocessed output:");
disp(head(otsuOutput));

%% 3. Check available variables

% The K-means output may include:
% - acquisition datetime
% - water VH/VV backscatter values
% - incidence angle
% - water-pixel count
% - water-pixel location
% - neighborhood mean backscatter statistics
% - optimal number of clusters
%
% The Otsu output may include:
% - acquisition datetime
% - water-pixel count
% - water-pixel location
% - threshold-based water body detection information
% - related SAR-derived feature values

disp("Variables in K-means output:");
disp(kmeansOutput.Properties.VariableNames');

disp("Variables in Otsu output:");
disp(otsuOutput.Properties.VariableNames');

%% 4. Tutorial example of confusion matrix-based evaluation

% In the full study, annual Sentinel-1-derived water body maps from each
% method were compared with ESA WorldCover reference water body data.
%
% Both datasets were binarized:
% 1 = water
% 0 = non-water
%
% Here, simplified binary vectors are used to demonstrate the calculation
% of evaluation metrics.

referenceWater = [1 1 1 0 0 0 1 1 0 0]';

kmeansWater = [1 1 0 0 0 1 1 1 0 0]';
otsuWater = [1 0 0 0 0 0 1 1 0 1]';

%% 5. Calculate metrics for K-means and Otsu

methods = ["K-means"; "Otsu"];
predictedWater = {kmeansWater, otsuWater};

Accuracy = zeros(2,1);
Precision = zeros(2,1);
Recall = zeros(2,1);
FAR = zeros(2,1);
F1_score = zeros(2,1);

for i = 1:numel(methods)

    pred = predictedWater{i};
    ref = referenceWater;

    TP = sum(pred == 1 & ref == 1);
    TN = sum(pred == 0 & ref == 0);
    FP = sum(pred == 1 & ref == 0);
    FN = sum(pred == 0 & ref == 1);

    Accuracy(i) = (TP + TN) / (TP + TN + FP + FN);
    Precision(i) = TP / (TP + FP);
    Recall(i) = TP / (TP + FN);
    FAR(i) = FP / (FP + TN);
    F1_score(i) = 2 * Precision(i) * Recall(i) / ...
                   (Precision(i) + Recall(i));
end

%% 6. Display evaluation summary

evaluationResults = table(methods, Accuracy, Precision, Recall, FAR, F1_score);

disp("Water body detection evaluation results:");
disp(evaluationResults);
