%% 04_Evaluate_water_level_estimation.m
% Tutorial script for LSTM-based water level estimation using Sentinel-1 SAR features.
%
% Programming environment:
% This tutorial is implemented in MATLAB, not Python.
%
% Purpose:
% This script demonstrates the main workflow for estimating water level
% using pre-synchronized Sentinel-1-derived input variables and an
% LSTM-based model.
%
% Note:
% This is a simplified tutorial example. It does not reproduce the full
% project-specific implementation, full temporal matching process,
% hyperparameter search, SHAP analysis, or station-wise batch processing
% used in the associated study.
%
% The sample Sentinel-1 feature file is assumed to have already been
% temporally matched with the corresponding ground-based water level
% observations.

clc; clear; close all;

%% 1. Set sample data directory

dataDir = fullfile("..", "Data", "Sample_Data");

s1FeatureFile = fullfile(dataDir, ...
    "Sentinel1_Features_Sample_K_means_Clustering.xlsx");

%% 2. Load pre-synchronized sample dataset

% The sample feature file is treated as a pre-synchronized dataset.
% It contains Sentinel-1 SAR-derived features and the corresponding
% ground-based water level observations.
%
% Therefore, this script does not perform temporal synchronization between
% Sentinel-1 acquisition times and water level records.

modelData = readtable(s1FeatureFile);

disp("Pre-synchronized Sentinel-1 feature and water level sample:");
disp(head(modelData));

%% 3. Standardize date-time information

% Sentinel-1 acquisition time
if ismember("acquisition_datetime", modelData.Properties.VariableNames)
    if ~isdatetime(modelData.acquisition_datetime)
        modelData.acquisition_datetime = datetime(modelData.acquisition_datetime, ...
            "InputFormat", "yyyy-MM-dd HH:mm:ss");
    end
end

%% 4. Prepare temporal variable

% Day of Year (DOY) is used as a temporal indicator.
if ~ismember("doy", modelData.Properties.VariableNames)
    modelData.doy = day(modelData.acquisition_datetime, "dayofyear");
end

%% 5. Select input variables and target variable

% Example input variables used in the associated study:
% - DOY
% - incidence angle
% - VH backscatter
% - VV backscatter
%
% The target variable is the ground-based water level.

inputVariableNames = [
    "doy"
    "incidence_angle_deg"
    "water_vh_backscatter_db"
    "water_vv_backscatter_db"
];

availableInputs = inputVariableNames(ismember(inputVariableNames, ...
    modelData.Properties.VariableNames));

X = modelData(:, availableInputs);
Y = modelData.water_level_m;

fprintf("\nSelected input variables:\n");
disp(availableInputs);

%% 6. Split high- and low-water level conditions

% In the associated study, water level data were partitioned into high- and
% low-water conditions using the median water level at each station.
%
% This tutorial demonstrates the concept using the sample dataset.

medianWaterLevel = median(Y, "omitnan");

idxHigh = Y >= medianWaterLevel;
idxLow = Y < medianWaterLevel;

% Example: use high-water condition.
% Users can switch to idxLow to train a low-water-level model.
selectedIdx = idxHigh;

X_selected = X(selectedIdx, :);
Y_selected = Y(selectedIdx);

if ismember("acquisition_datetime", modelData.Properties.VariableNames)
    T_selected = modelData.acquisition_datetime(selectedIdx);
else
    T_selected = (1:height(modelData))';
    T_selected = T_selected(selectedIdx);
end

fprintf("Number of high-water samples: %d\n", sum(idxHigh));
fprintf("Number of low-water samples : %d\n", sum(idxLow));

%% 7. Split data into training, validation, and testing periods

% Example split based on year:
% Training : 2015–2021
% Validation : 2022
% Testing : 2023–2024

if isdatetime(T_selected)

    yearValues = year(T_selected);

    idxTrain = yearValues >= 2015 & yearValues <= 2021;
    idxVal = yearValues == 2022;
    idxTest = yearValues >= 2023 & yearValues <= 2024;

else
    % Fallback split for sample data without datetime information.
    n = height(X_selected);
    idxTrain = false(n,1);
    idxVal = false(n,1);
    idxTest = false(n,1);

    idxTrain(1:round(0.7*n)) = true;
    idxVal(round(0.7*n)+1:round(0.85*n)) = true;
    idxTest(round(0.85*n)+1:end) = true;
end

XTrain = table2array(X_selected(idxTrain, :));
XVal = table2array(X_selected(idxVal, :));
XTest = table2array(X_selected(idxTest, :));

YTrain = Y_selected(idxTrain);
YVal = Y_selected(idxVal);
YTest = Y_selected(idxTest);

TTest = T_selected(idxTest);

%% 8. Define a simplified BiLSTM model

numFeatures = size(XTrain, 2);
numResponses = 1;

numHiddenUnits = 100;

layers = [
    sequenceInputLayer(numFeatures)
    bilstmLayer(numHiddenUnits, "OutputMode", "sequence")
    fullyConnectedLayer(numResponses)
    regressionLayer
];

options = trainingOptions("adam", ...
    "MaxEpochs", 100, ...
    "MiniBatchSize", 64, ...
    "InitialLearnRate", 0.001, ...
    "GradientThreshold", 0.5, ...
    "ValidationData", {XVal', YVal'}, ...
    "Verbose", false);

%% 9. Train LSTM model

% Input data are transposed to match MATLAB sequence input format.
net = trainNetwork(XTrain', YTrain', layers, options);

%% 10. Predict water level for test period

YPred = predict(net, XTest');

%% 11. Evaluate model performance

R_matrix = corrcoef(YTest', YPred);
R = R_matrix(1,2);

RMSE = sqrt(mean((YTest' - YPred).^2));
MAE = mean(abs(YTest' - YPred));

meanObs = mean(YTest);
IOA = 1 - sum((YPred - YTest').^2) / ...
    sum((abs(YPred - meanObs) + abs(YTest' - meanObs)).^2);

evaluationResults = table(R, RMSE, MAE, IOA);

disp("LSTM water level estimation results:");
disp(evaluationResults);

%% 12. Plot observed and predicted water levels

figure;
plot(TTest, YTest, "-o", "LineWidth", 1.5);
hold on;
plot(TTest, YPred, "--o", "LineWidth", 1.5);
grid on;

xlabel("Date");
ylabel("Water level (m)");
legend("Observed", "Predicted", "Location", "best");
title("Observed and Predicted Water Levels");
