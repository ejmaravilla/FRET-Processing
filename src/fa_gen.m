function fa_gen(fname,params,fold)

% A simple program to generate masks using the water program
% A typical set of params is [25,1000,25]

files = file_search(fname,fold);

for i = 1:length(files)
    img = double(imread(files{i}));
    w = water(img,params);
    imwrite2tif(w,[],fullfile(fold,['fa_' files{i}]),'single');
end

end