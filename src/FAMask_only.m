% This script applies masks generated on focal adhesions to all relevant
% imaging channels.
% For just corrected FRET, this includes "bsa","bsd", and "cna" channels
% For FRET efficiency, it adds on "eff" and "dpa" channels
% For FRET Coloc, it adds the stain channel

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
if strcmpi(Bchannel,Achannel)
    imageset{end+1} = ['fa_bsa_' prefix exp_name '\w+' Bchannel '.TIF'];
else
    imageset{end+1} = ['fa_' prefix exp_name '\w+' Bchannel '.TIF'];
end

if isempty(file_search('masked_\w+.TIF',folder))
    mkdir(folder,'Masked Images')
    app_mask(imageset,maskchannel,folder)
end
addpath(fullfile(folder,'Masked Images'))