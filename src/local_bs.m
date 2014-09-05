function local_bs(imagenames1, imagenames2, blur, folder)
% Function that allows for the local background subtraction on images of 
% two stains for future blob analysis separate from the raw images.
imgnames{1} = file_search(imagenames1,folder);
imgnames{2} = file_search(imagenames2,folder);
num_stains = length(imgnames);
num_imgs = length(imgnames{1});
h = fspecial('gaussian', [blur blur], blur);

for i = 1:num_stains
    for j = 1:num_imgs
        img = imread(imgnames{i}{j});
        blur = imfilter(img,h,'same');
        bimg = img - blur;
        imwrite2tif(bimg,[],fullfile(folder,['bslocal_' imgnames{i}{j}]),'single')
    end
end
end

