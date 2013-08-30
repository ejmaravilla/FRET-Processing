function image_registration_edit(ax,ay,dx,dy,fx,fy,varargin)
% Authorship
% Written by Andrew LaCroix on 7/31/13
% Modified by Katheryn Rothenberg on 8/13/13

afiles = file_search('\w+_w1Venus.TIF',varargin{end});

sz = size(imread(afiles{1}));
[y,x] = ndgrid(1:sz(1),1:sz(2));
if sz(1) == 1124
    crop2 = [50 50 1023 1023]; % if using center quadrant
else
    crop2 = [50 50 1947 1947]; % if using full image
end

for i = 1:length(afiles)
    aimg = single(imread(afiles{i}));
    areg = interp2(x,y,aimg,x-ax,y-ay);
    acrop = imcrop(areg,crop2);
    imwrite2tif(acrop,[],['reg_' afiles{i}],'uint16');
end

dfiles = file_search('\w+_w3Teal.TIF',varargin{end});
for i = 1:length(dfiles)
    dimg = single(imread(dfiles{i}));
    dreg = interp2(x,y,dimg,x-dx,y-dy);
    dcrop = imcrop(dreg,crop2);
    imwrite2tif(dcrop,[],['reg_' dfiles{i}],'uint16');
end

ffiles = file_search('\w+_w2TVFRET.TIF',varargin{end});
for i = 1:length(ffiles)
    fimg = single(imread(ffiles{i}));
    freg = interp2(x,y,fimg,x-fx,y-fy);
    fcrop = imcrop(freg,crop2);
    imwrite2tif(fcrop,[],['reg_' ffiles{i}],'uint16');
end

if nargin > 7
    stains = (nargin - 7)/3;
    for i = 1:stains
        sfiles = file_search(varargin{3*i-2},varargin{end});
        for j = 1:length(sfiles)
            simg = single(imread(sfiles{i}));
            sreg = interp2(x,y,simg,x-varargin{3*i-1},y-varargin{3*i});
            scrop = imcrop(sreg,crop2);
            imwrite2tif(scrop,[],['reg_' sfiles{i}],'uint16');
        end
    end
end

end