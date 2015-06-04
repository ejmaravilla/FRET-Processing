function [P] = cell_outline_simple1(img_file,thresh,folder)
%Generates P, which is the row, column coordinates of single cell outlines

% Read in image + median filter
thresh = thresh/3000; % Scale factor
I = imread(img_file);
I = 255.*I./3000; % Convert to 8 bit image
I = uint8(I);
bw = im2bw(I,thresh); % Make binary image

% Dilate then erode once to smooth
SE = strel('disk',3);
bw = imerode(bw,SE);
bw = imdilate(bw,SE);

D = -bwdist(~bw);
mask = imextendedmin(D,50);
D2 = imimposemin(D,mask); % Watershed from only certain seed regions
Ld2 = watershed(D2); % Find watershed boundaries with these seed constraints
bw(Ld2 == 0) = 0; % Add boundaries between cells
bw = imfill(bw,'holes'); % Fill holes after watershed

% Label each blob with 8-connectivity, so we can make measurements of it
% and get rid of small cells, save out masks and .dat files with
% coordinates to find in blob_file.
cells = bwareaopen(bw,10000); % exclude regions smaller than cellSizeThresh
cells = bwlabel(cells, 8);
P = bwboundaries(cells);
for i = 1:length(P)
    out = P{i};
    out(:,3) = out(:,1);
    out(:,1) = [];
    single_cell = poly2mask(out(:,1),out(:,2),1948,1948); % X and Y are reversed
    % when you use bwboundaries as opposed to contour
    single_cell = mat2gray(single_cell); % Convert in order to save to image
    single_cell = single_cell./(2^8);
    single_cell = im2uint8(single_cell);
    imwrite(single_cell,fullfile(folder,['polymask_cell' num2str(i) '_' img_file(1:end-4) '.png']));
%     imwrite2tif(single_cell,[],fullfile(folder,['polymask_cell' num2str(i) '_' img_file]),'single');
    save(fullfile(pwd,folder,['poly_cell' num2str(i) '_' img_file(1:end-4) '.dat']),'out','-ascii')        % Create image of just cell = i
end


% counter = 0;
% for i = 1:max(cells(:))
%     mask1 = cells == i;
%     cellSize = sum(mask1(:));
%     if cellSize < cellSizeThresh
%         cells = cells - i*mask1;
%     elseif cellSize >= cellSizeThresh
%         counter = counter + 1;
%         mask1(mask1>0) = counter;
%         mask = mat2gray(mask1);
%         imwrite2tif(mask,[],fullfile(folder,['polymask_cell' num2str(counter) '_' img_file]),'single');
%         [P{counter},~] = contour(mask,1,'Visible','off');
%         P{counter} = P{counter}';
%         P{counter}(1,:) = [];
%         out = P{counter};
%         save(fullfile(pwd,folder,['poly_cell' num2str(counter) '_' img_file(1:end-4) '.dat']),'out','-ascii')        % Create image of just cell = i
%     end
% end

% % Apply a variety of pseudo-colors to the regions and show user what the
% % cell outliner did
% close all
% colored_cells = label2rgb(cells,'hsv','k','shuffle');

% Write out tif of cells (grayscale, not rgb)
cells = cells./(2^8);
cells = im2uint8(cells);
% imwrite2tif(cells,[],fullfile(folder,['polymask_cells_' img_file]),'single');
imwrite(cells,fullfile(folder,['polymask_cells_' img_file(1:end-4) '.png']));
end

