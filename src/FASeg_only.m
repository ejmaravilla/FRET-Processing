% This script deals with only segmentation protocols for focal adhesion
% structures. It optimizes parameters if desired (optimize_params = 'y')
% and then generates focal adhesion masks based on these parameters.

rehash
if isempty(file_search('fa_\w+.TIF',folder))
    mkdir(folder,'FA Images')
    if strcmpi(optimize_params,'y')
        ImageNameCell = file_search([prefix exp_name '\w+\d+\w+' Bchannel '.TIF'],folder);
        if length(ImageNameCell) < 3
            l = length(ImageNameCell);
        else
            l = 3;
        end
        Values = zeros(l,3);
        for i = 1:l
            Image = double(imread(ImageNameCell{i}));
            Values(i,:) = ParameterSelectorFunction(Image,WidthRange,ThreshRange,MergeRange,blob_params);
        end
        blob_params = round(mean(Values));
    end
    if strcmpi(Bchannel,Achannel)
        fa_gen(['bsa_' prefix exp_name '\w+' Bchannel '.TIF'],blob_params,folder)
    else
        fa_gen([prefix exp_name '\w+' Bchannel '.TIF'],blob_params,folder)
    end
end
addpath(fullfile(folder,'FA Images'))