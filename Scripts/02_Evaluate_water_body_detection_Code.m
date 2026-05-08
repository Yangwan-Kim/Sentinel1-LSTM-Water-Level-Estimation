%% 02_Evaluate_water_body_detection.m
% Tutorial script for evaluating Sentinel-1-derived water body detection.
%
% Programming environment:
%   This tutorial is implemented in MATLAB, not Python.
%
% In the associated study, two water body detection approaches were used:
%   1) K-means clustering
%   2) Otsu thresholding
%
% The full Sentinel-1 water body extraction workflow is not included in
% this tutorial. Instead, this script uses final preprocessed output files
% generated from each method and demonstrates how water body detection
% results can be evaluated using confusion matrix-based metrics.
%
% K-means workflow summary:
%   - Sentinel-1 VH and VV backscatter images are clipped around each station.
%   - The optimal number of clusters is determined using silhouette analysis.
%   - K-means clustering is applied to classify SAR backscatter patterns.
%   - Water-related pixels are identified and used to extract feature values.
%
% Otsu workflow summary:
%   - Sentinel-1 VH and VV backscatter images are clipped around each station.
%   - Automatic thresholding is applied to separate water and non-water pixels.
%   - Water-related pixels are identified and summarized as feature values.
%
% This script is intended as a MATLAB tutorial example, not the full
% project-specific implementation.
