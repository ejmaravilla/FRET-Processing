function mask_img(filename,folder)

% saves masks corresponding to cells (drawn using boundary_dist) in single
% image

mask_names = file_search(filename,folder);
num_masks = length(mask_names);
temp = imread(mask_names{1});
img_size = size(temp);
masks = zeros(img_size);
for i = 1:num_masks
    mask = imread(mask_names{i});
    masks = masks+i*mask;
end

imwrite2tif(masks,[],fullfile(folder,['polymask_cells_' mask_names{1}(16:end)]),'single');

end

