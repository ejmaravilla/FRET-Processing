function [ParameterValues] = ThreshSelect(Image,ThreshRange,ParameterValues)

% A program that allows the user to manually optimize and select
% cell_thresh parameter

% Change contrast and set color
numColors = 1;
Colors = [0 1 0];
topval = prctile(Image(:),99.9);
ImagePlot = mat2gray(Image, [0 topval]);

% Determine Cells
% Read in image
Image = 255.*Image./10000; % Convert to 8 bit image
Image = uint8(Image);
bw = im2bw(Image,ParameterValues./10000); % Make binary image
bw = imfill(bw,'holes'); % Fill holes after watershed

CELL = bw;
CELLone = bw;
CELLone(CELLone>=1) = 1;
CELLoutline = bwperim(CELLone);
CELLcolor = CELLoutline .* CELL;

% Cell figure
hFig = figure;
hAx = axes('Parent',hFig);

imagesc(ImagePlot,'Parent',hAx)
colormap(gray)

% Show Cell outlines
hold on
for i = 1:numColors
    colorMask{i} = cat(3, Colors(i,1)*ones(size(CELL)), Colors(i,2)*ones(size(CELL)), Colors(i,3)*ones(size(CELL)));
    h{i} = imshow(colorMask{i},'Parent',hAx);
    x = rem(CELLcolor,numColors);
    set(h{i},'AlphaData',rem(CELLcolor,numColors)+1==i & CELLcolor~=0);
end
hold off

% Slider: Threshold
uicontrol('Parent',hFig,'Style','slider','Min',ThreshRange(1),'Max',ThreshRange(2),'Value',ParameterValues,'Position',[0 290 120 20],'SliderStep',[0.005 0.005],'Callback',@Change1);
hText1 = uicontrol('Style','text','Position',[0 310 120 20],'String',sprintf('Thresh: %d',ParameterValues));

w = waitforbuttonpress;
close all

    function Change1(hObj,event)
        % Change width value
        val = get(hObj,'value');
        ParameterValues = val;
        
        % Re-Determine Cell Outlines
        bw = im2bw(Image,ParameterValues./10000); % Make binary image
        bw = imfill(bw,'holes'); % Fill holes after watershed
        
        CELL = bw;
        CELLone = bw;
        CELLone(CELLone>=1) = 1;
        CELLoutline = bwperim(CELLone);
        CELLcolor = CELLoutline .* CELL;
        
        % Re-plot cell image
        imagesc(ImagePlot,'Parent',hAx)
        colormap(gray)
        
        % Show cell outlines
        hold on
        for i = 1:numColors
            colorMask{i} = cat(3, Colors(i,1)*ones(size(CELL)), Colors(i,2)*ones(size(CELL)), Colors(i,3)*ones(size(CELL)));
            h{i} = imshow(colorMask{i},'Parent',hAx);
            x = rem(CELLcolor,numColors);
            set(h{i},'AlphaData',rem(CELLcolor,numColors)+1==i & CELLcolor~=0);
        end
        hold off
        
        % Change text value
        set(hText1,'String',sprintf('Width: %d',ParameterValues))
    end

end