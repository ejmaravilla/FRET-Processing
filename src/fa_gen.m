function fa_gen(fname,params,fold)
% fa_gen('bsa_pre_VinTS\w+Venus.TIF,[25 500 50],'VinTS 093015')

% A simple program to generate and save masks using the water program.
% A typical set of params is [25,500,50].

files = file_search(fname,fold);

for i = 1:length(files)
    img = double(imread(files{i}));
    w = water(img,params);
    imwrite2tif(w,[],fullfile(fold,'FA Images',['fa_' files{i}]),'single');
end

end