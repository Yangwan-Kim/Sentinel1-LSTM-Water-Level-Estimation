%% 02_Evaluate_water_body_detection.m
% Tutorial script for water body detection and evaluation using Sentinel-1 SAR.
%
% Programming environment:
%   This tutorial is implemented in MATLAB, not Python.
%
% Purpose:
%   This script provides a simplified tutorial example of how Sentinel-1-derived
%   water body detection results can be evaluated using confusion matrix-based
%   metrics.
%
%   In the associated study, two water body detection approaches were used:
%     1) K-means clustering
%     2) Otsu thresholding
%
% Note:
%   This script does not reproduce the full project-specific workflow.
%   The original Sentinel-1 GRD preprocessing, station-wise clipping,
%   annual water body map generation, and ESA WorldCover raster comparison
%   are not included. Instead, this tutorial uses simplified example arrays
%   and final preprocessed sample outputs to demonstrate the main logic.

clc; clear; close all;

%% 1. Set data directory

dataDir = fullfile("..", "Data", "Sample_Data");

kmeansFile = fullfile(dataDir, ...
    "Sentinel1_Features_Sample_K_means_Clustering.xlsx");

otsuFile = fullfile(dataDir, ...
    "Sentinel1_Features_Sample_Otsu_Thresholding.xlsx");

%% 2. Load final preprocessed outputs

% These files are final preprocessed outputs generated from the K-means
% clustering and Otsu thresholding workflows.
%
% They are provided as sample-format outputs, not as original Sentinel-1
% GRD imagery.

kmeansOutput = readtable(kmeansFile);
otsuOutput   = readtable(otsuFile);

disp("K-means final preprocessed output:");
disp(head(kmeansOutput));

disp("Otsu final preprocessed output:");
disp(head(otsuOutput));

%% 3. Simplified K-means water body detection example

% In the full workflow, Sentinel-1 VH and VV backscatter images were clipped
% around each monitoring station. The optimal number of clusters was selected
% using silhouette analysis, and K-means clustering was applied to identify
% water-related pixels.
%
% Here, small example VH and VV arrays are used only to demonstrate the
% conceptual logic.

VH = [-21 -20 -19 -10 -9;
      -22 -21 -20 -11 -10;
      -23 -22 -21 -12 -11;
      -20 -19 -18 -9  -8];

VV = [-15 -14 -13 -7 -6;
      -16 -15 -14 -8 -7;
      -17 -16 -15 -9 -8;
      -14 -13 -12 -6 -5];

% Combine VH and VV backscatter values as input features.
X = [VH(:), VV(:)];

% Apply K-means clustering.
% In the full workflow, K was determined using silhouette analysis.
K = 2;
idx = kmeans(X, K, "Distance", "cityblock", "Replicates", 5);

% Reshape cluster labels back to image format.
kmeansLabelMap = reshape(idx, size(VH));

% In this simplified example, the cluster with the lowest mean VH backscatter
% is assumed to represent water because open water generally has low SAR
% backscatter.
meanVH = zeros(K,1);

for k = 1:K
    meanVH(k) = mean(VH(kmeansLabelMap == k), "all");
end

[~, waterCluster] = min(meanVH);

kmeansWaterMap = zeros(size(VH));
kmeansWaterMap(kmeansLabelMap == waterCluster) = 1;

disp("Simplified K-means water map:");
disp(kmeansWaterMap);

%% 4. Simplified Otsu thresholding water body detection example

% In the full workflow, Otsu thresholding was applied to station-clipped
% Sentinel-1 VH and VV backscatter images. Pixels classified as the lowest
% backscatter class in both VH and VV were treated as water-related pixels.
%
% Here, the same example VH and VV arrays are used to demonstrate the logic.

numThresholds = 1;

level_VH = multithresh(VH, numThresholds);
level_VV = multithresh(VV, numThresholds);

label_VH = imquantize(VH, level_VH);
label_VV = imquantize(VV, level_VV);

otsuWaterMap = zeros(size(VH));
otsuWaterMap(label_VH == 1 & label_VV == 1) = 1;

disp("Simplified Otsu water map:");
disp(otsuWaterMap);

%% 5. Confusion matrix-based evaluation

% In the full study, annual Sentinel-1-derived binary water maps were
% compared with ESA WorldCover reference water body data.
%
% Here, a simplified reference map is used to demonstrate the metric
% calculation.
%
% 1 = water
% 0 = non-water

referenceWaterMap = [1 1 1 0 0;
                     1 1 1 0 0;
                     1 1 1 0 0;
                     1 1 1 0 0];

methods = ["K-means"; "Otsu"];
predictedMaps = {kmeansWaterMap, otsuWaterMap};

Accuracy  = zeros(2,1);
Precision = zeros(2,1);
Recall    = zeros(2,1);
FAR       = zeros(2,1);
F1_score  = zeros(2,1);

for i = 1:numel(methods)

    pred = predictedMaps{i};
    ref  = referenceWaterMap;

    TP = sum(pred == 1 & ref == 1, "all");
    TN = sum(pred == 0 & ref == 0, "all");
    FP = sum(pred == 1 & ref == 0, "all");
    FN = sum(pred == 0 & ref == 1, "all");

    Accuracy(i)  = (TP + TN) / (TP + TN + FP + FN);
    Precision(i) = TP / (TP + FP);
    Recall(i)    = TP / (TP + FN);
    FAR(i)       = FP / (FP + TN);
    F1_score(i)  = 2 * Precision(i) * Recall(i) / ...
                   (Precision(i) + Recall(i));
end

evaluationResults = table(methods, Accuracy, Precision, Recall, FAR, F1_score);

disp("Water body detection evaluation results:");
disp(evaluationResults);
