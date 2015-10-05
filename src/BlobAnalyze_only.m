% This script organizes relevant files into a certain logical order and
% passes them onto the blob analyze function to calculate average value of
% each channel within the structures defined by the mask image.

rehash
imageset = {['bsa_' prefix exp_name '\w+' Achannel '.TIF'],...
    ['bsd_' prefix exp_name '\w+' Dchannel '.TIF']};
if strcmpi(Coloc,'y')
    imageset{end+1} = [prefix exp_name '\w+' Schannel '.TIF'];
end
if strcmpi(FRETeff,'y')
    imageset{end+1} = ['dpa_' prefix exp_name '\w+' FRETchannel '.TIF'];
end
imageset{end+1} = ['cna_' prefix exp_name '\w+' FRETchannel '.TIF'];
if strcmpi(FRETeff,'y')
    imageset{end+1} = ['eff_' prefix exp_name '\w+' FRETchannel '.TIF'];
end
imageset{end+1} = ['fa_bsa_' prefix exp_name '\w+' Bchannel '.TIF'];

if isempty(file_search('blb_\w+.txt',folder))
    mkdir(folder,'Average Images')
    col_labels = blob_analyze(imageset,FRETeff,sizemin,sizemax,exp_name,Bchannel,folder);
end
addpath(fullfile(folder,'Average Images'))