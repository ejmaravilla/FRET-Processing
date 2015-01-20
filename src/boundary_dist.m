function newcols = boundary_dist(imgexp,filename,folder,closed_open,manual,reg_calc,rat,pre_exist,num_channel)

% This function calculates the distance from the edge of provided blobs. It
% functions on manually drawing closed/open polygons, providing pre-defined
% polygons (must be closed?),or automatically generating closed polygons.

img_col = 2*num_channel+7;
if strcmpi(closed_open,'closed') && strcmpi(manual,'y') && strcmpi(pre_exist,'n')
    files = file_search(imgexp,folder);
    d = load(filename);
    [m,~] = size(d);
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
        im = imread(files{i});
        [im_w, im_h] = size(im);
        figure; imagesc(im);
        cell_num = input('how many cells would you like to select?');
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
            imwrite2tif(mask,[],fullfile(folder,['polymask_cell' num2str(k) '_' files{i}]),'single');
            save(fullfile(pwd,folder,['poly_cell' num2str(k) '_' files{i}(1:end-4) '.dat']),'P','-ascii')
            rehash
            if strcmpi(reg_calc,'y')
                [cell_col_img(:,k),dists_img(:,k),cell_area(:,k),cell_ecc(:,k),...
                    cell_cent_x(:,k), cell_cent_y(:,k), cell_convex_area(:,k),...
                    cell_per(:,k), cell_center_dist(:,k), cell_major_axis_length(:,k),...
                    cell_minor_axis_length(:,k), cell_orientation(:,k)]...
                    = app_poly_blobs_cells(filename,fullfile(pwd,folder,['poly_cell' num2str(k) '_'...
                    files{i}(1:end-4) '.dat']),['polymask_cell' num2str(k) '_' files{i}],i,k,num_channel);
            elseif strcmpi(reg_calc,'n')
                [cell_col_img(:,k),dists_img(:,k)] = app_poly_blobs(filename,fullfile(pwd,folder,['poly_cell' num2str(k) '_' files{i}(1:end-4) '.dat']),i,k,num_channel);
            end
        end
        if strcmpi(reg_calc,'y')
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
            newcols = [dist_col...
                cell_col...
                cell_area_col...
                cell_ecc_col...
                cell_cent_x_col...
                cell_cent_y_col...
                cell_convex_area_col...
                cell_per_col...
                cell_center_dist_col...
                cell_major_axis_length_col...
                cell_minor_axis_length_col...
                cell_orientation_col];
        elseif strcmpi(reg_calc,'n')
            cell_col(rows) = sum(cell_col_img,2); % Fix for overlapping boundaries
            dist_col(rows) = sum(dists_img,2);
            close all;
            newcols = [dist_col cell_col];
        end
    end
    
elseif strcmpi(closed_open,'open') && strcmpi(manual,'y') && strcmpi(pre_exist,'n')
    files = file_search(imgexp,folder);
    d = load(filename);
    [m,~] = size(d);
    u = unique(d(:,img_col));
    [o,~] = size(u);
    
    dist_col = zeros(m,1);
    for i = 1:o
        im = imread(files{i});
        figure; imagesc(im);
        v = 1;
        while v == 1;
            M = imfreehand(gca,'Closed',0);
            v = input('Keep region (yes = pressENTER, no = press1)?');
        end
        P0 = M.getPosition;
        D = round([0; cumsum(sum(abs(diff(P0)),2))]);
        P = interp1(D,P0,D(1):.5:D(end));
        P = unique(round(P),'rows');
        save(fullfile(pwd,folder,['line_' files{i}(1:end-4) '.dat']),'P','-ascii')
        rows = find(d(:,img_col)==i);
        dists_img = zeros(length(rows),1);
        for j = 1:length(rows)
            all_dist = sqrt((d(rows(j),1)-P(:,1)).^2 + (d(rows(j),2)-P(:,2)).^2);
            min_dist = min(all_dist);
            dists_img(j) = min_dist;
        end
        dist_col(rows) = dists_img;
        newcols = dist_col;
        close all;
    end
    
elseif strcmpi(closed_open,'closed') && strcmpi(manual,'n') && strcmpi(pre_exist,'n')
    files = file_search(imgexp,folder);
    d = load(filename);
    [m,~] = size(d);
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
    ratioThresh = rat;
    for i = 1:o
        P0 = cell_outline_simple1(files{i},ratioThresh,folder);
        rehash
        cell_num = length(P0);
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
        for k = 1:cell_num
            if strcmpi(reg_calc,'y')
                [cell_col_img(:,k),dists_img(:,k),cell_area(:,k),cell_ecc(:,k), cell_cent_x(:,k), cell_cent_y(:,k), cell_convex_area(:,k), cell_per(:,k), cell_center_dist(:,k), cell_major_axis_length(:,k), cell_minor_axis_length(:,k), cell_orientation(:,k)] = app_poly_blobs_cells(filename,fullfile(pwd,folder,['poly_cell' num2str(k) '_' files{i}(1:end-4) '.dat']),['polymask_cell' num2str(k) '_' files{i}],i,k,num_channel);
            elseif strcmpi(reg_calc,'n')
                [cell_col_img(:,k),dists_img(:,k)] = app_poly_blobs(filename,fullfile(pwd,folder,['poly_cell' num2str(k) '_' files{i}(1:end-4) '.dat']),i,k,num_channel);
            end
        end
        if strcmpi(reg_calc,'y')
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
            newcols = [dist_col cell_col cell_area_col cell_ecc_col cell_cent_x_col cell_cent_y_col cell_convex_area_col cell_per_col cell_center_dist_col cell_major_axis_length_col cell_minor_axis_length_col cell_orientation_col];
        elseif strcmpi(reg_calc,'n')
            cell_col(rows) = sum(cell_col_img,2); % Fix for overlapping boundaries
            dist_col(rows) = sum(dists_img,2);
            close all;
            newcols = [dist_col cell_col];
        end
    end
    
elseif strcmpi(pre_exist,'y')
    files = file_search(imgexp,folder);
    d = load(filename);
    [m,~] = size(d);
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
        im = imread(files{i});
        poly_files = file_search(['poly_cell\d+_' files{i}(1:end-4) '.dat'],folder);
        cell_num = length(poly_files);
        [im_w, im_h] = size(im);
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
        for k = 1:cell_num
            P = load(poly_files{k});
            mask1 = poly2mask(P(:,1), P(:,2), im_w, im_h);
            mask = mat2gray(mask1);
            imwrite2tif(mask,[],fullfile(folder,['polymask_cell' num2str(k) '_' files{i}]),'single');
            rehash
            if strcmpi(reg_calc,'y')
                [cell_col_img(:,k),dists_img(:,k),cell_area(:,k),cell_ecc(:,k), cell_cent_x(:,k), cell_cent_y(:,k), cell_convex_area(:,k), cell_per(:,k), cell_center_dist(:,k), cell_major_axis_length(:,k), cell_minor_axis_length(:,k), cell_orientation(:,k)] = app_poly_blobs_cells(filename,fullfile(pwd,folder,['poly_cell' num2str(k) '_' files{i}(1:end-4) '.dat']),['polymask_cell' num2str(k) '_' files{i}],i,k,num_channel);
            elseif strcmpi(reg_calc,'n')
                [cell_col_img(:,k),dists_img(:,k)] = app_poly_blobs(filename,fullfile(pwd,folder,['poly_cell' num2str(k) '_' files{i}(1:end-4) '.dat']),i,k,num_channel);
            end
        end
        if strcmpi(reg_calc,'y')
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
            newcols = [dist_col cell_col cell_area_col cell_ecc_col cell_cent_x_col cell_cent_y_col cell_convex_area_col cell_per_col cell_center_dist_col cell_major_axis_length_col cell_minor_axis_length_col cell_orientation_col];
        elseif strcmpi(reg_calc,'n')
            cell_col(rows) = sum(cell_col_img,2); % Fix for overlapping boundaries
            dist_col(rows) = sum(dists_img,2);
            close all;
            newcols = [dist_col cell_col];
        end
    end
end