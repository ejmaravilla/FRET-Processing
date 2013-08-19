function img_cropper(imgexp,folder)

tagstruct.Photometric = 1;
tagstruct.PlanarConfiguration = 1;
tagstruct.Compression= 1;
tagstruct.BitsPerSample = 32;
tagstruct.SampleFormat = 3;
tagstruct.ImageWidth = 1024;
tagstruct.ImageLength = 1024;

files = file_search(imgexp,folder);
for i = 1:length(files)
    a = double(imread(files{i}));
    acrop = a(513:1536,513:1536);
    t = Tiff([folder '\crop_' files{i}],'w');
    t.setTag(tagstruct);
    t.write(single(acrop));
    t.close();
end

end