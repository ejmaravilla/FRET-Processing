function local_bs(img_names,fa_img_names, blur, rf, folder)
% Function that allows for the local background subtraction on images of 
% two stains for future blob analysis separate from the raw images.
imgnames{1} = file_search(img_names,folder);
fa_imgnames{1} = file_search(fa_img_names,folder);
num_stains = length(imgnames);
num_imgs = length(imgnames{1});
h = fspecial('gaussian', [blur blur], blur);

for i = 1:num_stains
    for j = 1:num_imgs
        % Load images and make FA img binary and inverted
        img = imread(imgnames{i}{j}); % Raw stain image
        faimg = imread(fa_imgnames{i}{j}); % Raw FA image
        faimg(faimg > 0) = 2;
        faimg(faimg == 0) = 1;
        faimg(faimg == 2) = rf;
        % Create blurred image where all FA intensities are set to some fraction (rf) of the
        % intensity of stains in FAs
        blur_img3 = img.*faimg;
        blur_img2 = imfilter(blur_img3,h,'same');
        blur_img1 = img - blur_img2;
        imwrite2tif(blur_img3,[],fullfile(folder,['bslocal3_' imgnames{i}{j}]),'single')
        imwrite2tif(blur_img2,[],fullfile(folder,['bslocal2_' imgnames{i}{j}]),'single')
        imwrite2tif(blur_img1,[],fullfile(folder,['bslocal1_' imgnames{i}{j}]),'single')
    end
end
end