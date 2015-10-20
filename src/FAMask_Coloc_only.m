% This script applies masks generated on focal adhesions to all relevant
% imaging channels.
% For just corrected FRET, this includes "bsa","bsd", and "cna" channels
% For FRET efficiency, it adds on "eff" and "dpa" channels
% For FRET Coloc, it adds the stain channel

rehash
imageset = {[prefix exp_name '\w+' Schannel '.TIF'],...
    [prefix exp_name '\w+' Schannel2 '.TIF']};
imageset{end+1} = ['fa_' prefix exp_name '\w+' Bchannel '.TIF'];

if isempty(file_search('masked_\w+.TIF',folder))
    mkdir(folder,'Masked Images')
    app_mask(imageset,maskchannel,folder)
end
addpath(fullfile(folder,'Masked Images'))