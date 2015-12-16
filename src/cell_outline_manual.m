function [P] = cell_outline_manual(img_files,folder)
% Generates masks manually based on user-drawn regions with imfreehand

imgs = file_search(img_files,folder);

for i = 1:length(imgs)
    % Read in image + median filter
    im = single(imread(imgs{i}));
    % Autothreshold for viewing 1% overexposed
%     viewthresh = quantile(im(:),0.99);
    viewthresh = 5000;
    % Show image and select cells
    [im_w, im_h] = size(im);
    figure; imagesc(im,[0 viewthresh]);
    cell_num = input('how many cells would you like to select?');
    for k = 1:cell_num
        v = 1;
        while v == 1;
            M = imfreehand(gca);
            v = input('Keep region (1 = no, anything = yes)?');
        end
        P0 = M.getPosition;
        D = round([0; cumsum(sum(abs(diff(P0)),2))]);
        P = interp1(D,P0,D(1):.5:D(end));
        mask1 = poly2mask(P(:,1), P(:,2), im_w, im_h);
        mask = mat2gray(mask1);
        mask = mask./(2^8);
        mask = im2uint8(mask);
        imwrite(mask,fullfile(folder,'Cell Mask Images',['polymask_cell' num2str(k) '_' imgs{i}(1:end-4) '.png']));
        save(fullfile(folder,'Cell Mask Images',['poly_cell' num2str(k) '_' imgs{i}(1:end-4) '.dat']),'P','-ascii')
        rehash
        if k == 1
            cells = mask;
        else
            cells = cells + k*mask;
        end
    end
    imwrite(cells,fullfile(folder,'Cell Mask Images',['polymask_cells_' imgs{i}(1:end-4) '.png']));
    close all;
end