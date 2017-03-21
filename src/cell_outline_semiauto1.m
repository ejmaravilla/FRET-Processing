function cell_outline_semiauto1(img_files,thresh,folder)
% Generates cell masks automatically based on user-adjusted threshold
% (through ThreshSelect.m). Always requires the user to use ThreshSelect.m
% to optimize threshold parameter.

imgs = file_search(img_files,folder);

% % Generate threshold to be applied across images
% if length(imgs) < 3
%     n_test_imgs = length(imgs);
% else
%     n_test_imgs = 3;
% end
% for i = 1:n_test_imgs
%     Image = double(imread(imgs{i}));
%     [ParameterValues] = ThreshSelect(Image,[0 5000],thresh);
%     t(i) = ParameterValues;
% end
% thresh = mean(t)/10000; % Scale factor
for i = 1:length(imgs)
    % Read in image + localnormalize
    I = imread(imgs{i});
    lnI = localnormalize(I,100,100);
%     lnI = lnI + 0.1;
%     I = 255.*I./10000; % Convert to 8 bit image
%     I = uint8(I);
    bw = im2bw(lnI,thresh); % Make binary image
    
    % Dilate then erode once to smooth
    SE = strel('disk',2);
    bw = imerode(bw,SE);
    bw = imdilate(bw,SE);
    
    D = -bwdist(~bw);
    mask = imextendedmin(D,50);
    D2 = imimposemin(D,mask); % Watershed from only certain seed regions
    Ld2 = watershed(D2); % Find watershed boundaries with these seed constraints
    bw(Ld2 == 0) = 0; % Add boundaries between cells
    bw = imfill(bw,'holes'); % Fill holes after watershed
    bw = bwareaopen(bw,15000,4);
    
    %% User separates cells
    viewthresh = 7000;
    [im_w, im_h] = size(I);
    figure('Position',[100 100 800 800]);
    imagesc(I,[0 viewthresh]);
    colormap jet
    hold on
    B = bwboundaries(bw);
    for k = 1:length(B)
        scatter(B{k}(:,2),B{k}(:,1),'SizeData',6);
    end
    separation_num = input('how many cells do you need to separate?');
    for k = 1:separation_num
        v = 1;
        while v == 1;
            M = imfreehand(gca,'Closed',0);
            v = input('Keep line (1 = no, anything = yes)?');
        end
        P0 = M.getPosition;
        D = round([0; cumsum(sum(abs(diff(P0)),2))]);
        P = interp1(D,P0,D(1):.5:D(end));
        P = round(P,0);
        for k = 1:length(P)
            bw(P(k,2),P(k,1)) = 0;
        end
    end
    %% User decides which cells to keep
    close all
    figure('Position',[100 100 800 800]);
    imagesc(I,[0 viewthresh]);
    colormap jet
    hold on
    B = bwboundaries(bw);
    for k = 1:length(B)
        scatter(B{k}(:,2),B{k}(:,1),'SizeData',6);
    end
    cell_num = input('how many cells do you want to keep?');
    CC = bwconncomp(bw,4);
    bw_new = zeros(1948,1948);
    for k = 1:cell_num
        M = imfreehand(gca,'Closed',0);
        P0 = M.getPosition;
        P = round(P0);
        Pind = sub2ind([1948,1948],P(2),P(1));
        for m = 1:length(CC.PixelIdxList)
            PC = CC.PixelIdxList{m};
            if ismember(Pind,PC)
                bw_new(PC) = 1;
            else
            end
        end
    end
    close
    
    
    % Label each blob with 8-connectivity, so we can make measurements of it
    % and get rid of small cells, save out masks and .dat files with
    % coordinates to find in blob_file.
    cells = bwareaopen(bw_new,10000); % exclude regions smaller than cellSizeThresh
    cells = bwlabel(cells, 4);
    P = bwboundaries(cells,4);
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

