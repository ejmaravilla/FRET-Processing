function [folder,params_file] = GetParamsFile(varargin)

% This script obtains the relevant folder containing the images to be
% analyzed.

if (not(isempty(varargin)))
    folder = varargin{1};
else
    folder = input(['Type the full path of the folder that contains your images, '...
        'name your files so they look like \n"exp_01_w1Achannel.TIF", '...
        '"exp_01_w2FRETchannel.TIF", and "exp_01_w3Dchannel.TIF" : '],'s');
end

params_file = file_search('Exp_Param\w+.txt',folder);