function final = water3(imOrig,parray)
% WATER
%    A segmentation program based on the algorithm of Zamir et al. (1999)
%    JCS.  Also see Grashoff et al. (2010) Nature.
%
%    The program is meant to read-in a pre-flattened file.  This program
%    does not perform flattening - only thresholding.

% edits made by Katheryn Rothenberg:
%   receive two inputs - the original image, and array containing the
%       threshold, minimum patch area, and critical patch size for merging
%   return the final label matrix
%   changed line 60 to line 61 so that it was not always a true statement
%   added line 53 to reinitialize the int array for each iteration

%   water3 uses parameter 1 as the average filter high_pass_filt_width to perform the
%   highpass filtering and has no size restriction on the focal adhesions

%% User Input

% filePath = 'sample images\iii-107z4 flat.tif'; %file path and name
% thresh = 10;     %threshold
% areaL = 10;       %minimum patch area
% mergeL = 4;      %critical patch size for merging

tic;
% areaL = parray(1);
high_pass_filt_width = parray(1);
thresh = parray(2);
mergeL = parray(3);


%% Image Loading and Prep. for Analysis

% imOrig = double(imread(filePath)); %load image, convert to double format
AvgFilt = fspecial('average',high_pass_filt_width);
SmImg = filter2(AvgFilt,imOrig);
FiltImg = double(imOrig) - SmImg;
im = FiltImg.*(FiltImg > thresh);      %threshold (should eliminate any negative values)

%The following code might try to lookup a pixel value outside the image
%size, so add a layer of zeros to deal with that possibility. We will
%remove the layer at the end of processing.
mat = padarray(im, [1 1]);     %pads matrix with 0s on all sides

% im_label = bwlabel(im > 0,8);
% props = regionprops(im_label,'Area');
% small_FA = ismember(im_label,find([props.Area] < mergeL*2));
% labelMat = bwlabel(small_FA,8);
% im(small_FA) = 0;

[r,c,v] = find(mat);          %collect non-zero values [v] and their location [r,c]
list = [r c v];               %pacakge output vectors into one matrix
list = sortrows(list, -3);    %sorts rows by v (brightest to dimmest)

%% Identify Patches

labelMat = zeros(size(mat));  %pre-allocate matrix to collect patch numbers
patchNum = max(labelMat(:)) + 1;   %independent index for patch labels
for i = 1:size(list,1)
    hood = getEight(list(i,1:2), labelMat);  %look in 'hood for existing patches
    patchList = unique(nonzeros(hood));      %find unique, non-zero patch labels
    
    switch length(patchList)  
        case 0                             %no patches in 'hood
            labelMat(list(i,1),list(i,2)) = patchNum; %assign new patch number
            patchNum = patchNum+1;
        case 1                             %one neighboring patch
            labelMat(list(i,1),list(i,2)) = patchList; %assign to the existing patch
        otherwise                          %>1 neighboring patch
            allInd = []; int = []; sz = [];
            for j = 1:length(patchList)    %for each patch in the list
                ind = find(labelMat == patchList(j)); %find all pixels with corresponding patch number
                sz(j) = length(ind);       %#ok<AGROW> %patch size
                int(j) = sum(sum(mat(ind)));    %#ok<AGROW> %patch integrated intensity
                allInd = [allInd; ind];    %#ok<AGROW> %collect all indicies
            end
                        
            %This bit of code finds the index in the patchList that has the
            %highest intensity, but only considers the patch numbers with
            %enough size to avoid being merged. This patch number is then
            %merged/assigned to the current pixel or other adjacent
            %patches.
            [~, brightest_large_patch_index] = max((sz >= mergeL) .* int);
            brightest_large_patch_num = patchList(brightest_large_patch_index);
            
            doesnt_meet_size_nums = patchList(sz < mergeL);
            for small_patch_num = doesnt_meet_size_nums'
                labelMat(labelMat == small_patch_num) = brightest_large_patch_num;
            end
            labelMat(list(i,1),list(i,2)) = brightest_large_patch_num;
    end
end

%% Clean-up Patch List
labelMat = sparse(labelMat);            %convert to sparse matrix format to increase speed
patches = nonzeros(unique(labelMat));   %all patch numbers
newNum = 1;                             %initialize new patch number assignments
for j = 1:length(patches)
%     ind = find(labelMat == patches(j)); %find indicies of the patch
%     if length(ind) < areaL              %if patch is too small, remove
%         labelMat(ind) = 0.1;            %set to 0.1 to preserve nonzero element structure of the sparse matrix
%     else
        labelMat(labelMat == patches(j)) = newNum;         %else, re-number so there are no skipped patch numbers
        newNum = newNum+1;
%     end
end
labelMat = floor(labelMat);             %set any 0.1 to 0
labelMat = full(labelMat);              %convert back to full matrix format

%% Output: Statistics and Images

final = labelMat(2:(size(labelMat,1)-1), 2:(size(labelMat,2)-1)); %remove padding

%stats = regionprops(labelMat, 'Area', 'MajorAxisLength', 'MinorAxisLength');

rgb = label2rgb(final, 'jet', 'k', 'shuffle');
figure
subplot(1,2,1);
imagesc(imOrig);
% axis image;
subplot(1,2,2);
imagesc(rgb);
axis image;

%imwrite(uint8(final),'sample images\test.tif','tif','compression','none');
toc;
return

%% Sub Functions

function hood = getEight(index, mat)
% finds pixels with eight-point connectivity to the input pixel
r = index(1);
c = index(2);

hood = [
    mat(r-1,c-1)
    mat(r-1,c  )
    mat(r-1,c+1)
    mat(r  ,c-1)
    mat(r  ,c+1)
    mat(r+1,c-1)
    mat(r+1,c  )
    mat(r+1,c+1) 
    ];
return

function hood = getFour(index, mat)
% finds pixels with four-point connectivity to the input pixel
r = index(1);
c = index(2);

hood = [
    mat(r-1,c  )
    mat(r  ,c-1)
    mat(r  ,c+1)
    mat(r+1,c  )
    ];
return
