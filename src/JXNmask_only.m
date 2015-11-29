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
imageset{end+1} = ['JXN_bsa_' prefix exp_name '\w+' Bchannel '.TIF'];

if isempty(file_search('masked_\w+.TIF',folder))
    mkdir(folder,'Masked Images')
    app_mask(imageset,maskchannel,folder)
end
addpath(fullfile(folder,'Masked Images'))