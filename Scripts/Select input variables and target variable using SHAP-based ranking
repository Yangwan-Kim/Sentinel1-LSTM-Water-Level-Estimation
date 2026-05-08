%% 3. Select input variables and target variable using SHAP-based ranking

% Example input variables used in the associated study:
% - DOY
% - incidence angle
% - VH backscatter
% - VV backscatter
%
% In the full study, SHAP analysis was used to interpret the relative
% contribution of each input variable and to guide feature selection.
%
% This tutorial does not reproduce the full SHAP calculation. Instead, it
% demonstrates how a pre-defined SHAP-based feature ranking can be used to
% organize input variables for LSTM-based water level estimation.

shapBasedFeatureOrder = [
    "doy"
    "incidence_angle_deg"
    "water_vh_backscatter_db"
    "water_vv_backscatter_db"
];

% Keep only variables that exist in the sample dataset.
availableInputs = shapBasedFeatureOrder(ismember(shapBasedFeatureOrder, ...
    modelData.Properties.VariableNames));

% Create input and target datasets.
X = modelData(:, availableInputs);
Y = modelData.water_level_m;

fprintf("\nSelected input variables based on SHAP-guided ranking:\n");
disp(availableInputs);
