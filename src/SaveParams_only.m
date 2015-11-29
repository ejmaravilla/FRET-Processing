rehash
params_file = file_search('Exp_Param\w+.txt',folder);
fid = fopen(fullfile(folder,params_file{1}),'a');
fprintf(fid,'\n\nfolder = ''%s'';',folder);
fprintf(fid,'\nfinal_blob_params = [%d %d %d];',blob_params(1),blob_params(2),blob_params(3));
if exist('cell_thresh','var')
    fprintf(fid,'\ncell_thresh = %d;',cell_thresh*10000);
end
fclose(fid);
rmpath(genpath(folder))