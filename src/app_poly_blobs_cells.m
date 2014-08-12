function [cell_col_img, dists_img, cell_area, cell_ecc, cell_cent_x, cell_cent_y, cell_convex_area, cell_per, cell_center_dist, cell_major_axis_length, cell_minor_axis_length, cell_orientation] = app_poly_blobs_cells(blobfile,polyfile,maskfile,imgnum,cellnum,num_channel)

% This function generates columns to add to blob files that contain cell
% parameters along with distance from edge calculations

img_col = 2*num_channel+7;
mask = imread(maskfile);
blb = load(blobfile);
poly = load(polyfile);
rows = find(blb(:,img_col)==imgnum); % Correspond to the image rows
dists_img = zeros(length(rows),1);
cell_area = zeros(length(rows),1);
cell_ecc = zeros(length(rows),1);
cell_convex_area = zeros(length(rows),1);
cell_per = zeros(length(rows),1);
cell_cent_x = zeros(length(rows),1);
cell_cent_y = zeros(length(rows),1);
cell_center_dist = zeros(length(rows),1);
cell_major_axis_length = zeros(length(rows),1);
cell_minor_axis_length = zeros(length(rows),1);
cell_orientation = zeros(length(rows),1);


[props] = regionprops(mask,'FilledArea','Eccentricity','Centroid','ConvexArea','Perimeter','MajorAxisLength','MinorAxisLength','Orientation');
cell_area(:,1) = props.FilledArea;
cell_ecc(:,1) = props.Eccentricity;
cell_convex_area(:,1) = props.ConvexArea;
cell_per(:,1) = props.Perimeter;
cell_cent_x(:,1) = props.Centroid(1);
cell_cent_y(:,1) = props.Centroid(2);
cell_major_axis_length(:,1) = props.MajorAxisLength;
cell_minor_axis_length(:,1) = props.MinorAxisLength;
cell_orientation(:,1) = -deg2rad(props.Orientation);

inpoly = inpolygon(blb(rows,1),blb(rows,2),poly(:,1),poly(:,2));
for j = 1:length(rows)
    all_dist = sqrt((blb(rows(j),1)-poly(:,1)).^2 + (blb(rows(j),2)-poly(:,2)).^2);
    min_dist = min(all_dist);
    dists_img(j) = min_dist;
    cell_center_dist(j) = sqrt((blb(rows(j),1)-cell_cent_x(1,1)).^2 + (blb(rows(j),2)-cell_cent_y(1,1)).^2);
end
dists_img = dists_img.*inpoly;
cell_col_img = inpoly.*cellnum;
cell_area = cell_area.*inpoly;
cell_ecc = cell_ecc.*inpoly;
cell_convex_area = cell_convex_area.*inpoly;
cell_per = cell_per.*inpoly;
cell_cent_x = cell_cent_x.*inpoly;
cell_cent_y = cell_cent_y.*inpoly;
cell_center_dist = cell_center_dist.*inpoly;
cell_major_axis_length = cell_major_axis_length.*inpoly;
cell_minor_axis_length = cell_minor_axis_length.*inpoly;
cell_orientation = cell_orientation.*inpoly;
