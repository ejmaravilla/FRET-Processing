function newcols = boundary_dist(blb_file,files,folder)

% This function calculates the distance from the edge of provided blobs. It
% functions on manually drawing  polygons, providing pre-defined
% polygons,or automatically generating polygons.

d = load(blb_file);
[m,img_col] = size(d);
img_names = file_search(files,folder);
u = unique(d(:,img_col));
[o,~] = size(u);

cell_col = zeros(m,1);
dist_col = zeros(m,1);
cell_area_col = zeros(m,1);
cell_ecc_col = zeros(m,1);
cell_cent_x_col = zeros(m,1);
cell_cent_y_col = zeros(m,1);
cell_convex_area_col = zeros(m,1);
cell_per_col = zeros(m,1);
cell_center_dist_col = zeros(m,1);
cell_major_axis_length_col = zeros(m,1);
cell_minor_axis_length_col = zeros(m,1);
cell_orientation_col = zeros(m,1);

for i = 1:o
    im = single(imread(img_names{i}));
    poly_files = file_search(['poly_cell\d+_' img_names{i}(1:end-4) '.dat'],folder);
    cell_num = length(poly_files);
    [~, ~] = size(im);
    rows = find(d(:,img_col)==i);
    
    dists_img = zeros(length(rows),cell_num);
    cell_col_img = zeros(length(rows),cell_num);
    cell_area = zeros(length(rows),cell_num);
    cell_ecc = zeros(length(rows),cell_num);
    cell_cent_x = zeros(length(rows),cell_num);
    cell_cent_y = zeros(length(rows),cell_num);
    cell_convex_area = zeros(length(rows),cell_num);
    cell_per = zeros(length(rows),cell_num);
    cell_center_dist = zeros(length(rows),cell_num);
    cell_major_axis_length = zeros(length(rows),cell_num);
    cell_minor_axis_length = zeros(length(rows),cell_num);
    cell_orientation = zeros(length(rows),cell_num);
    
    rehash
    for k = 1:cell_num
        polyfile = fullfile(folder,'Cell Mask Images',['poly_cell' num2str(k) '_' img_names{i}(1:end-4) '.dat']);
        maskfile = fullfile(folder,'Cell Mask Images',['polymask_cell' num2str(k) '_' img_names{i}(1:end-4) '.png']);
        [cell_col_img(:,k),...
            dists_img(:,k),...
            cell_area(:,k),...
            cell_ecc(:,k),...
            cell_cent_x(:,k),...
            cell_cent_y(:,k),...
            cell_convex_area(:,k),...
            cell_per(:,k),...
            cell_center_dist(:,k),...
            cell_major_axis_length(:,k),...
            cell_minor_axis_length(:,k),...
            cell_orientation(:,k)] = app_poly_blobs(blb_file,polyfile,maskfile,i,k);
    end
    cell_col(rows) = sum(cell_col_img,2); % Fix for overlapping boundaries
    dist_col(rows) = sum(dists_img,2);
    cell_area_col(rows) = sum(cell_area,2);
    cell_ecc_col(rows) = sum(cell_ecc,2);
    cell_cent_x_col(rows) = sum(cell_cent_x,2);
    cell_cent_y_col(rows) = sum(cell_cent_y,2);
    cell_convex_area_col(rows) = sum(cell_convex_area,2);
    cell_per_col(rows) = sum(cell_per,2);
    cell_center_dist_col(rows) = sum(cell_center_dist,2);
    cell_major_axis_length_col(rows) = sum(cell_major_axis_length,2);
    cell_minor_axis_length_col(rows) = sum(cell_minor_axis_length,2);
    cell_orientation_col(rows) = sum(cell_orientation,2);
    
    close all;
    newcols = [cell_col...
        dist_col...
        cell_center_dist_col...
        cell_area_col...
        cell_convex_area_col...
        cell_per_col...
        cell_major_axis_length_col...
        cell_minor_axis_length_col...
        cell_major_axis_length_col./cell_minor_axis_length_col... % Changed from cell_ecc_col
        cell_orientation_col...
        cell_cent_x_col...
        cell_cent_y_col];
    newcols(isnan(newcols)) = 0;
end