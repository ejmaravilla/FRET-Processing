% This script organizes relevant files into a certain logical order and
% passes them onto the blob analyze function to calculate average value of
% each channel within the structures defined by the mask image.

rehash
imageset = {[prefix exp_name '\w+' Schannel '.TIF'],...
    [prefix exp_name '\w+' Schannel2 '.TIF']};
imageset{end+1} = ['fa_' prefix exp_name '\w+' Bchannel '.TIF'];

if isempty(file_search('blb_\w+.txt',folder))
    mkdir(folder,'Average Images')
    col_labels = blob_analyze(imageset,FRETeff,sizemin,sizemax,exp_name,Bchannel,folder);
end
addpath(fullfile(folder,'Average Images'))