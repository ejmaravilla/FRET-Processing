% This script performs pre-processing functions for FRET and FRET Coloc
% experiments, including conversion of .lsm files to .TIF files, and
% application of corrections such as registration, shade correction, and
% background subtraction.

% Note: If you want to subtract a particular value off of each image as
% background subtraction, make sure you have a variable called "bvals" that
% has your chosen background value for each imaging channel.

%% If files are .lsm, convert to .TIF
rehash
if ~isempty(file_search('\w+.lsm',folder))
    lsm2tif1([exp_name '\w+.lsm'],folder,{Achannel,FRETchannel,Dchannel});
end

%% Preprocess images using PreParams.mat file in GoogleDrive (Protocols -> Analysis Protocols -> FRET)
rehash
if isempty(file_search('pre_\w+.TIF',folder))
    mkdir(fullfile(folder,'Preprocessed Images'))
    preparams = file_search(PreParams_file,pwd);
    if exist('bvals','var')
        preprocess(preparams{1},folder,bvals)
    else
        preprocess(preparams{1},folder)
    end
end
addpath(fullfile(folder,'Preprocessed Images'))