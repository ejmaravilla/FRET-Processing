function MAIN_COLOC(varargin)

%% Header
% This is a main function for running Coloc Code on a single
% experimental group. The Exp_Params text file in the folder containing the data
% should describe all relevant information for a particular experimental design.
% Sample Exp_params text files can be found in the GitHub repository.

%% Parameter Processing
% Check to see if anything has been passed as parameter, if anything has
% been passed, make sure it is a folder.

if (not(isempty(varargin)))
    if (exist(varargin{1},'dir'))
        folder = varargin{1};
    else
        error('Expected first parameter to be a folder with images to process.');
    end
else
    %% Set up
    clear;
    close all;
    clc;
end

%% Read in Pre-processing parameters

if (exist('folder','var'))
    [~,params_file] = GetParamsFile(folder); %%#ok<ASGLU>
else
    [folder,params_file] = GetParamsFile; %%#ok<ASGLU>
end
ProcessParamsFile;

%% Pre-process

PreProcess_only

%% segmentation
if strcmpi(segmentation,'y')
    if strcmpi(structure,'FA')
        FASeg_Coloc_only
    end
end

%% Mask Images
if strcmpi(mask,'y')
    if strcmpi(structure,'FA') && strcmpi(segmentation,'y')
        FAMask_Coloc_only
    end
end

%% Blob Analysis
if strcmpi(segmentation,'y') && strcmpi(banalyze,'y')
    BlobAnalyze_Coloc_only
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