function [P] = cell_outline_simple(img_file,thresh,folder)
%Generates P, which is the row, column coordinates of single cell outlines

% Read in image + median filter
Image = single(imread(img_file));
[r,~] = size(Image);
Image = medfilt2(Image,[10 10]);
Image = Image - thresh;

% Make binary + fill holes
binaryImage = im2bw(Image,0.01);
binaryImage = imfill(binaryImage,'holes');

% imerode, then imexpand
SE = strel('disk',7);
eImage = imerode(binaryImage,SE);
eeImage = imdilate(eImage,SE);

% Label each blob with 8-connectivity, so we can make measurements of it
% and get rid of small cells, save out masks and .dat files with
% coordinates to find in blob_file.
cells = bwlabel(eeImage, 8);
cellSizeThresh = ((1948*1948)/100);
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
%         P{counter}(:,2) = r-P{counter}(:,2);
%         tempCol = P{counter}(:,1);
%         P{counter}(:,1) = P{counter}(:,2);
%         P{counter}(:,2) = tempCol;
%         outline = bwperim(mask,8);
%         [tempRow,tempCol] = find(outline==1);
%         P{counter} = horzcat(tempCol,tempRow); % Is this supposed to be row column or column  row???
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

