% This script adds relevant folder containing the images to be analyzed and
% reads in experimental parameters from the Exp_Params text file.

addpath(folder)
params_file = file_search('Exp_Param\w+.txt',folder);
fid = fopen(params_file{1});
while ~feof(fid)
    aline = fgetl(fid);
    eval(aline)
end
fclose(fid);