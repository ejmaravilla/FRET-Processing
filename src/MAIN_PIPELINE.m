%% Header
% This is a main function for running FRET or FRET Coloc Code on a single
% experimental group. The Exp_Params text file in the folder containing the data
% should describe all relevant information for a particular experimental design.
% Sample Exp_params text files can be found in the GitHub repository.

%% Set up
clear;
close all;
clc;

%% Read in parameters

GetParams_only

%% Pre-process

PreProcess_only

%% Run FRET correction, does FRET efficiency if desired

FRET_only

%% Segmentation
if strcmpi(segment,'y')
    if strcmpi(structure,'FA')
        FASeg_only
    end
end

%% Mask Images
if strcmpi(mask,'y')
    if strcmpi(structure,'FA') && strcmpi(segment,'y')
        FAMask_only
    end
end

%% Blob Analysis
if strcmpi(segment,'y') && strcmpi(banalyze,'y')
    BlobAnalyze_only
end

%% Draw Boundaries
if strcmpi(draw_boundaries,'y')
    DrawBoundaries_only
end

%% Add Boundary Properties to Blob Analysis Results
if strcmpi(add_boundary_props,'y')
    AddBoundaryProps_only
end

%% Update parameters
SaveParams_only