function shade_correct(bkgexp,sampexp,folder)

% shading corrections
% sample/normbackground
% must do for each channel - donor only, acceptor only, experimental images

% Inputs:
% bkgexp - regular expression for the background (shading correction)
%   images
% sampexp - regular expression for the sample images to be corrected
% folder - folder containing files

% Outputs:
% updated image files

bfiles = file_search(bkgexp,folder);
a = imread(bfiles{1});
[r,c] = size(a);
btot = zeros(r,c);
for i = 1:length(bfiles)
    btot = btot + double(imread(bfiles{i}));
end
bmean = btot./length(bfiles);
bmeansub = bmean;
[X,Y] = meshgrid(1:r,1:c);
x = reshape(X,numel(X),1);
y = reshape(Y,numel(Y),1);
z = reshape(bmeansub,numel(bmeansub),1);
sf = fit([x,y],z,'poly22');
Z = feval(sf,[x,y]);
bsurf = reshape(Z,r,c);
bnorm = bsurf./max(max(bsurf));
% plot3(X,Y,bnorm)
% imwrite2tif(bnorm,[],[folder '\Shade_TVFRET.tif'],'uint16');

sfiles = file_search(sampexp,folder);
for i = 1:length(sfiles)
    s = double(imread(sfiles{i}));
    s(s >= (2^16-1)) = -1;
    snew = s./bnorm;
%     snew = (2^16).*(snew - min(min(snew)))./(max(max(snew))-min(min(snew)));
    imwrite2tif(snew,[],[folder '\sc_' sfiles{i}],'uint16');
end