function fa_gen(fname,params,fold)

% A simple program to look over water for multiple files
% A typical set of params is [25,100,15]

files = file_search(fname,fold);

for i = 1:length(files)
    img = double(imread(files{i}));
%     w = water2(img,params);
    w = water3(img,params);
    tagstruct.Photometric = 1;
    tagstruct.PlanarConfiguration = 1;
    tagstruct.Compression= 1;
    tagstruct.BitsPerSample = 32;
    tagstruct.SampleFormat = 3;
    tagstruct.ImageWidth = size(w,2);
    tagstruct.ImageLength = size(w,1);
    t = Tiff([fold '\fa_' files{i}], 'w');
    t.setTag(tagstruct);
    t.write(single(w));
    t.close();
end

end