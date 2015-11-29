% This script deals with only segmentation protocols for focal adhesion
% structures. It optimizes parameters if desired (optimize_params = 'y')
% and then generates focal adhesion masks based on these parameters.

rehash
if isempty(file_search('JXN_\w+.TIF',folder))
    mkdir(folder,'JXN Images')
    JXN_gen(['bsa_' prefix exp_name '\w+' Bchannel '.TIF'],folder)
end
addpath(fullfile(folder,'JXN Images'))