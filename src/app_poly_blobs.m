function [cell_col_img,dists_img] = app_poly_blobs(blobfile,polyfile,imgnum,cellnum,num_channel)

% This function generates columns to add to blob files that contain distance from edge calculations

img_col = 2*num_channel+7;
blb = load(blobfile);
poly = load(polyfile);
rows = find(blb(:,img_col)==imgnum);
dists_img = zeros(length(rows),1);

inpoly = inpolygon(blb(rows,1),blb(rows,2),poly(:,1),poly(:,2));
for j = 1:length(rows)
    all_dist = sqrt((blb(rows(j),1)-poly(:,1)).^2 + (blb(rows(j),2)-poly(:,2)).^2);
    min_dist = min(all_dist);
    dists_img(j) = min_dist;
end
dists_img = dists_img.*inpoly;
cell_col_img = inpoly.*cellnum;
