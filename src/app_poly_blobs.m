function [cell_col_img,dists_img] = app_poly_blobs(blobfile,polyfile,maskfile,imgnum,cellnum,num_channel)

% This function generates columns to add to blob files that contain distance from edge calculations

mask = imread(maskfile);
img_col = 4*num_channel+7;
blb = load(blobfile);
poly = load(polyfile);
rows = find(blb(:,img_col)==imgnum);

inpoly = inpolygon(blb(rows,1),blb(rows,2),poly(:,1),poly(:,2));
mask(mask > 0) = 1;
inv_mask = imcomplement(mask);
D = bwdist(inv_mask);
Dinds = sub2ind(size(D),round(blb(rows,2)),round(blb(rows,1)));
dists_img = D(Dinds);
cell_col_img = inpoly.*cellnum;
