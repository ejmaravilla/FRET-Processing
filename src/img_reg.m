function img_reg(prefix,folder)
% Authorship
% Written by Andrew LaCroix on 7/31/13
% Modified by Katheryn Rothenberg on 8/13/13
% Modified by Andrew LaCroix on 10/14/13
% Modified by Katheryn Rothenberg on 2/17/14

shifts = xlsread('img_reg_121713.xlsx');
F = shifts(1,:);
V = shifts(2,:);
T = shifts(3,:);
S = shifts(4,:);
TR = shifts(5,:);
FITC = shifts(6,:);
DAPI = shifts(7,:);

vfiles = file_search([prefix '\w+Venus.TIF'],folder);
if ~isempty(vfiles)
    sz = size(imread(vfiles{1}));
    [y,x] = ndgrid(1:sz(1),1:sz(2));
    if sz(1) == 1024
        crop2 = [5 5 1013 1013]; % if using center quadrant
    else
        crop2 = [5 5 2038 2038]; % if using full image
    end

    for i = 1:length(vfiles)
        vimg = single(imread(vfiles{i}));
        vreg = interp2(x,y,vimg,x-V(1),y-V(2));
        vcrop = imcrop(vreg,crop2);
        imwrite2tif(vcrop,[],fullfile(folder,['reg_' vfiles{i}]),'single')
    end   
end

tfiles = file_search([prefix '\w+Teal.TIF'],folder);
if ~isempty(tfiles)
    sz = size(imread(tfiles{1}));
    [y,x] = ndgrid(1:sz(1),1:sz(2));
    if sz(1) == 1024
        crop2 = [5 5 1013 1013]; % if using center quadrant
    else
        crop2 = [5 5 2038 2038]; % if using full image
    end
    
    for i = 1:length(tfiles)
        timg = single(imread(tfiles{i}));
        treg = interp2(x,y,timg,x-T(1),y-T(2));
        tcrop = imcrop(treg,crop2);
        imwrite2tif(tcrop,[],fullfile(folder,['reg_' tfiles{i}]),'single')
    end
end

ffiles = file_search([prefix '\w+TVFRET.TIF'],folder);
if ~isempty(ffiles)
    sz = size(imread(ffiles{1}));
    [y,x] = ndgrid(1:sz(1),1:sz(2));
    if sz(1) == 1024
        crop2 = [5 5 1013 1013]; % if using center quadrant
    else
        crop2 = [5 5 2038 2038]; % if using full image
    end
    for i = 1:length(ffiles)
        fimg = single(imread(ffiles{i}));
        freg = interp2(x,y,fimg,x-F(1),y-F(2));
        fcrop = imcrop(freg,crop2);
        imwrite2tif(fcrop,[],fullfile(folder,['reg_' ffiles{i}]),'single')
    end
end

sfiles = file_search([prefix '\w+Cy5.TIF'],folder);
if ~isempty(sfiles)
    sz = size(imread(sfiles{1}));
    [y,x] = ndgrid(1:sz(1),1:sz(2));
    if sz(1) == 1024
        crop2 = [5 5 1013 1013]; % if using center quadrant
    else
        crop2 = [5 5 2038 2038]; % if using full image
    end
    for i = 1:length(sfiles)
        simg = single(imread(sfiles{i}));
        sreg = interp2(x,y,simg,x-S(1),y-S(2));
        scrop = imcrop(sreg,crop2);
        imwrite2tif(scrop,[],fullfile(folder,['reg_' sfiles{i}]),'single')
    end
end

trfiles = file_search([prefix '\w+TR.TIF'],folder);
if ~isempty(trfiles)
    sz = size(imread(trfiles{1}));
    [y,x] = ndgrid(1:sz(1),1:sz(2));
    if sz(1) == 1024
        crop2 = [5 5 1013 1013]; % if using center quadrant
    else
        crop2 = [5 5 2038 2038]; % if using full image
    end
    for i = 1:length(trfiles)
        trimg = single(imread(trfiles{i}));
        trreg = interp2(x,y,trimg,x-TR(1),y-TR(2));
        trcrop = imcrop(trreg,crop2);
        imwrite2tif(trcrop,[],fullfile(folder,['reg_' trfiles{i}]),'single')
    end
end

fcfiles = file_search([prefix '\w+FITC.TIF'],folder);
if ~isempty(fcfiles)
    sz = size(imread(fcfiles{1}));
    [y,x] = ndgrid(1:sz(1),1:sz(2));
    if sz(1) == 1024
        crop2 = [5 5 1013 1013]; % if using center quadrant
    else
        crop2 = [5 5 2038 2038]; % if using full image
    end
    for i = 1:length(fcfiles)
        fcimg = single(imread(fcfiles{i}));
        fcreg = interp2(x,y,fcimg,x-FITC(1),y-FITC(2));
        fccrop = imcrop(fcreg,crop2);
        imwrite2tif(fccrop,[],fullfile(folder,['reg_' fcfiles{i}]),'single')
    end
end


dafiles = file_search([prefix '\w+DAPI.TIF'],folder);
if ~isempty(dafiles)
    sz = size(imread(dafiles{1}));
    [y,x] = ndgrid(1:sz(1),1:sz(2));
    if sz(1) == 1024
        crop2 = [5 5 1013 1013]; % if using center quadrant
    else
        crop2 = [5 5 2038 2038]; % if using full image
    end
    for i = 1:length(dafiles)
        daimg = single(imread(dafiles{i}));
        dareg = interp2(x,y,daimg,x-DAPI(1),y-DAPI(2));
        dacrop = imcrop(dareg,crop2);
        imwrite2tif(dacrop,[],fullfile(folder,['reg_' dafiles{i}]),'single')
    end
end

end