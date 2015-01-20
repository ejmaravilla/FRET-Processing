function [P] = cell_outline_simple1(img_file,thresh,folder)
%Generates P, which is the row, column coordinates of single cell outlines

% Read in image + median filter
thresh = thresh/65535;
I = imread(img_file);
I = 255.*I./65535; % Convert to 8 bit image
I = uint8(I);
bw = im2bw(I,thresh); % Make binary image
D = -bwdist(~bw);
mask = imextendedmin(D,50);
D2 = imimposemin(D,mask); % Watershed from only certain seed regions
Ld2 = watershed(D2); % Find watershed boundaries with these seed constraints
bw(Ld2 == 0) = 0; % Add boundaries between cells
bw = imfill(bw,'holes'); % Fill holes after watershed

% Label each blob with 8-connectivity, so we can make measurements of it
% and get rid of small cells, save out masks and .dat files with
% coordinates to find in blob_file.
cells = bwlabel(bw, 8);
cellSizeThresh = ((1948*1948)/200);
counter = 0;
for i = 1:max(cells(:))
    mask1 = cells == i;
    cellSize = sum(mask1(:));
    if cellSize < cellSizeThresh
        cells = cells - i*mask1;
    elseif cellSize >= cellSizeThresh
        counter = counter + 1;
        mask1(mask1>0) = counter;
        mask = mat2gray(mask1);
        imwrite2tif(mask,[],fullfile(folder,['polymask_cell' num2str(counter) '_' img_file]),'single');
        [P{counter},~] = contour(mask,1,'Visible','off');
        P{counter} = P{counter}';
        P{counter}(1,:) = [];
        out = P{counter};
        save(fullfile(pwd,folder,['poly_cell' num2str(counter) '_' img_file(1:end-4) '.dat']),'out','-ascii')        % Create image of just cell = i
    end
end

% Apply a variety of pseudo-colors to the regions and show user what the
% cell outliner did
close all
colored_cells = label2rgb(cells,'hsv','k','shuffle');

% Write out tif of cells (grayscale, not rgb)
imwrite2tif(cells,[],fullfile(folder,['polymask_cells_' img_file]),'single');
end

