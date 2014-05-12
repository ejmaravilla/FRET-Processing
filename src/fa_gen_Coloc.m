function fa_gen_Coloc(fname,params,fold,bkg)

% A simple program to look over water for multiple files
% A typical set of params is [25,1000,25], this _Coloc version allows for
% the additional subtraction of background before finding FAs (minimizes
% secondary antibody aggregate noise and speeds up code).

files = file_search(fname,fold);

for i = 1:length(files)
    img = double(imread(files{i}));
    img1 = (img-bkg).*(img>bkg);
    w = water(img1,params);
    imwrite2tif(w,[],fullfile(fold,['fa_' files{i}]),'single');
end

end