rehash
params_file = file_search('Exp_Param\w+.txt',folder);
fid = fopen(fullfile(folder,params_file{1}),'a');
fprintf(fid,'\n\nfolder = ''%s''',folder);
fprintf(fid,'\nfinal_blob_params = [%d %d %d];',blob_params(1),blob_params(2),blob_params(3));
if exist('cell_thresh','var')
    fprintf(fid,'\ncell_thresh = %d;',cell_thresh*10000);
end
fclose(fid);
rmpath(folder)
rmpath(fullfile(folder,'Average Images'))
rmpath(fullfile(folder,'Cell Mask Images'))
rmpath(fullfile(folder,'FA Images'))
rmpath(fullfile(folder,'FRET Correct Images'))
rmpath(fullfile(folder,'Masked Images'))
rmpath(fullfile(folder,'Preprocessed Images'))