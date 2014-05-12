function [P] = CellSelectorFunction(im,idealSquareSize,ratioThresh,sizeThresh)

%% Image Info
image = imread(im);
imageSize = size(image);
imageSize = imageSize(1);

%% Resize Image

difference = 2048-imageSize;
if rem(difference,2) == 0
    image = horzcat(zeros(imageSize,difference/2),image,zeros(imageSize,difference/2));
    image = vertcat(zeros(difference/2,2048),image,zeros(difference/2,2048));
else
    image = horzcat(zeros(imageSize,difference/2+0.5),image,zeros(imageSize,difference/2-0.5));
    image = vertcat(zeros(difference/2+0.5,2048),image,zeros(difference/2-0.5,2048));
end

%% Square Size

squareSize = idealSquareSize;
while 2048/squareSize ~= round(2048/squareSize)
    squareSize = squareSize + 1;
end
numSquares = 2048/squareSize;

%% Split Up Image

meanImageVal = mean(image(:));

goodSquare = zeros(numSquares);
for row = 1:numSquares
    for col = 1:numSquares
        
        imageSquare = image((row-1)*squareSize+1:row*squareSize,(col-1)*squareSize+1:col*squareSize);
        squareSum = sum(imageSquare(:));
        squareMean(row,col) = squareSum/(squareSize^2);
        
        if squareMean(row,col)/meanImageVal >= ratioThresh
            goodSquare(row,col) = 1;
        end
    end
end

%% Separate Cells

cells = bwlabel(goodSquare,4);

cellSizeThresh = round(numSquares^2*sizeThresh);
for i = 1:max(cells(:))
    mask = cells==i;
    cellSize = sum(mask(:));
    if cellSize < cellSizeThresh
        cells = cells - i*mask;
    end
end

cells = cells~=0;
cells = imfill(cells,'holes');
cells = bwlabel(cells,4);
cells = imresize(cells, [2048 2048], 'nearest');

outlines = bwperim(cells);
outlines = outlines .* cells;

for i = 1:max(outlines(:))
    temp = outlines==i;
    [tempRow,tempCol] = find(temp);
    P{i} = horzcat(tempCol,tempRow);
end

% %% Resize Image
% 
% if rem(difference,2) == 0
%     image = image(difference/2+1:imageSize+difference/2,difference/2+1:imageSize+difference/2);
%     outlines = outlines(difference/2+1:imageSize+difference/2,difference/2+1:imageSize+difference/2);
% else
%     image = image(difference/2+1.5:imageSize+difference/2,difference/2+1:imageSize+difference/2+0.5);
%     outlines = outlines(difference/2+1.5:imageSize+difference/2,difference/2+1:imageSize+difference/2+0.5);
% end
%
% %% Print image
% topval = prctile(image(:),99.9);
% ImagePlot = mat2gray(image, [0 topval]);
% 
% hFig = figure;
% hAx = axes('Parent',hFig);
% imagesc(ImagePlot)
% colormap gray, colorbar
% hold on
% 
% Colors = distinguishable_colors(max(outlines(:)),'k');
% for i = 1:max(outlines(:))
%     colorMask{i} = cat(3, Colors(i,1)*ones(size(outlines)), Colors(i,2)*ones(size(outlines)), Colors(i,3)*ones(size(outlines)));
%     h{i} = imshow(colorMask{i},'Parent',hAx);
%     x = rem(outlines,max(outlines(:)));
%     set(h{i},'AlphaData',rem(outlines,max(outlines(:)))+1==i & outlines~=0);
% end
% 
% hold off
% print('-r500','-dpng',printName)