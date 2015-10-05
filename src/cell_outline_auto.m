function thresh = cell_outline_auto(img_files,thresh,folder)
% Generates cell masks automatically based on user-adjusted threshold
% (through ThreshSelect.m). Always requires the user to use ThreshSelect.m
% to optimize threshold parameter.

imgs = file_search(img_files,folder);

% Generate threshold to be applied across images
if length(imgs) < 3
    n_test_imgs = length(imgs);
else
    n_test_imgs = 3;
end
for i = 1:n_test_imgs
    Image = double(imread(imgs{i}));
    [ParameterValues] = ThreshSelect(Image,[0 10000],thresh);
    t(i) = ParameterValues;
end
thresh = mean(t)/10000; % Scale factor

for i = 1:length(imgs)
    % Read in image + median filter
    I = imread(imgs{i});
    I = 255.*I./10000; % Convert to 8 bit image
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
    for j = 1:length(P)
        out = P{j};
        out(:,3) = out(:,1);
        out(:,1) = [];
        single_cell = poly2mask(out(:,1),out(:,2),1948,1948); % X and Y are reversed
        % when you use bwboundaries as opposed to contour
        single_cell = mat2gray(single_cell); % Convert in order to save to image
        single_cell = single_cell./(2^8);
        single_cell = im2uint8(single_cell);
        imwrite(single_cell,fullfile(folder,'Cell Mask Images',['polymask_cell' num2str(j) '_' imgs{i}(1:end-4) '.png']));
        save(fullfile(folder,'Cell Mask Images',['poly_cell' num2str(j) '_' imgs{i}(1:end-4) '.dat']),'out','-ascii')        % Create image of just cell = i
    end
    % Write out tif of cells (grayscale, not rgb)
    cells = cells./(2^8);
    cells = im2uint8(cells);
    imwrite(cells,fullfile(folder,'Cell Mask Images',['polymask_cells_' imgs{i}(1:end-4) '.png']));
end
end

