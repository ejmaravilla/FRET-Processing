% This script obtains the relevant folder containing the images to be
% analyzed, adds it to the path, and reads in experimental parameters from
% the Exp_Params text file.

folder = input('Type the full path of the folder that contains your images, name your files so they look like \n"exp_01_w1Achannel.TIF", "exp_01_w2FRETchannel.TIF", and "exp_01_w3Dchannel.TIF" : ','s');
addpath(folder)
params_file = file_search('Exp_Param\w+.txt',folder);
fid = fopen(params_file{1});
while ~feof(fid)
    aline = fgetl(fid);
    eval(aline)
end
fclose(fid);