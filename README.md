# Sentinel-1 and LSTM-based Water Level Estimation in a Regulated River Basin

This repository provides a tutorial-style MATLAB workflow associated with the study “Sentinel-1 and LSTM-based Water Level Estimation in a Regulated River Basin.”

The purpose of this repository is to support reproducibility and transferability by providing example scripts and sample-format data for the main methodological steps, rather than releasing the full project-specific implementation.

## Workflow

The tutorial covers the following steps:

1. Input data preparation  
2. Sentinel-1 SAR feature formatting  
3. LSTM model training  
4. Model evaluation  
5. Visualization of observed and predicted water levels  

## Input Variables

The example workflow uses the following input variables:

- Sentinel-1 SAR-derived VH Backscatter [dB]
- Sentinel-1 SAR-derived VV Backscatter [dB]
- Incidence angle
- Day of Year (DOY)

The target variable is ground-based water level observation.

## Repository Structure

```text
Data/
  Sample_Data/
    Station_Sample.xlsx
    Water_level_sample.xlsx
    Sentinel1_Features_Sample_K_means_Clustering.xlsx
    Sentinel1_Features_Sample_Otsu_Thresholding.xlsx

scripts/
  01_prepare_input_data.m
  02_train_lstm_model.m
  03_evaluate_model.m
  04_visualize_results.m
