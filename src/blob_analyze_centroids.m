function blob_analyze_centroids(bases,keywords)

% A function to analyze the same blobs across images from different
% channels using a provided mask.
% Inputs:
%   bases - a cell array containing regular expressions representing each
%   image channel that you would like to analyze separated by commas, with
%   the last one being the regular expression for the masks (can use the
%   results of fa_gen)
%   keywords - a structure containing necessary parameters
%       keywords.folder - name of the folder where images are contained
%       keywords.sizemin - a threshold for size under which you will ignore blobs (usually set to 15 for focal adhesions)
%       keywords.sizemax - a threshold for size over which you will ignore blobs (usually set to 10000 for focal adhesions)
%       keywords.outname - what you would like to name your output file
% Outputs:
%   blb file
%       A txt file beginning with blb_anl_ that stores a bunch of data
%       calculated. Each row is a different blob and each column is a
%       calculated value. N represents the number of image channels input.
%           Col 1 - x position of blob
%           Col 2 - y position of blob
%           Col 3:N*2+1 - average intensity of channels
%           Col 4:N*2+2 - standard deviation of channels
%           Col N*2+3 - size of blob in pixels
%           Col N*2+4 - major axis/minor axis of ellipse fit
%           Col N*2+5 - orientation in radians of ellipse fit
%           Col N*2+6 - blob identification number (from water)
%           Col N*2+7 - frame/image number
%   tavg file
%       A txt file beginning with tavg_ that averages parameters across
%       each frame/image number. Each row is a different frame/image and
%       each column is the mean of the calculated values from blb file. N
%       represents the number of image channels input.
%           Col 1 - image/frame number
%           Col 2:N*2 - average intensity of channels in an image/frame
%           Col 3:N*2+1 - standard deviation of intensities in an image/frame
%           Col N*2+2 - average size of blob in an image/frame
%           Col N*2+3 - average axis ratio in an image/frame
%           Col N*2+4 - average orientation in an image/frame
%           Col N*2+5 - number of blobs in an image/frame
%   avg images
%       A set of images beginning with avg_ that are the masked input
%       images with the values contained in each blob averaged together to
%       create a mean intensity for each blob.
% Sample Call:
%   keywords.sizemin = 15;
%   keywords.sizemax = 10000;
%   keywords.folder = 'Stain 101513';
%   keywords.outname = fullfile(pwd,keywords.folder,'VTP Stain 101513');
%   blob_analyze({'Vinculin_\d+_w1FW FITC.TIF','Talin_\d+_w2FW Cy5.TIF','Paxillin_\d+_w3FW TR.TIF','fa_Vinculin_\d+_w1FW FITC.TIF'},keywords)
%   This applies the masks of the form fa_Vinculin_\d+_w1FW FITC.TIF to the
%   three image channels (Vinculin, Talin, Paxillin), all found in the
%   folder Stain 101513. It only looks at blobs of 15<size<10000. It will
%   output two text files: blb_VTP Stain 101513.txt and tavg_VTP Stain 101513.txt
%   along with a set of images starting with avg_
% Required Functions:
%   file_search
%   imwrite2tif
%
% This code 'blob_analyze' should be considered 'freeware' and may be
% distributed freely (outside of the military-industrial complex) in its
% original form when properly attributed.

imgn = imgn_check(bases,keywords.folder);

szn = size(imgn);
nch = szn(2);
nt = szn(1);
dims = size(double(imread(imgn{1,1})));

resind = 2*(nch)+2*(nch-1);
szstr = resind+1;
ecstr = resind+2;
orstr = resind+3;
idstr = resind+4;
tstr = resind+5;

colvec = [3:2:resind,resind+1:resind+3];
nvec = length(colvec);

res = zeros(1,resind+5);
sres = [];

for i = 1:nt
    starr = zeros(dims(1),dims(2),nch-1);
    imgarr = read_chnls(imgn(i,:));
    
    cimg = imgarr{nch-1};
    bimg = imgarr{nch}; % blob mask image
    
    sbimg = sort(bimg(:));
    [~,u] = unique(sbimg);
    del = u-circshift(u,1);
    wbe = find(del > keywords.sizemin & del < keywords.sizemax); % find large enough blobs
    wbe = wbe-1;
    lim = length(wbe);
    
    for j = 1:lim
        mp = sbimg(u(wbe(j)));
        in = find(bimg == mp);
        nwnz = length(in);
        res(szstr) = nwnz;
        
        [xind,yind] = ind2sub(dims,in);
        nvecp = length(xind);
        
        mcimg = cimg(in);
        tb = sum(mcimg);
        res(2) = sum(xind)./length(xind);
        res(1) = sum(yind)./length(yind);
        
        for k = 1:nch-1
            if k <= 2 % assumes FRET index & FRET efficiency are first 2 channels
                inv_img = 1./imgarr{k}(in);
                res(2*k+1) = sum(inv_img.*yind)./sum(inv_img);
                res(2*k+2) = sum(inv_img.*xind)./sum(inv_img);
            else
                res(2*k+1) = sum(imgarr{k}(in).*yind)./sum(imgarr{k}(in));
                res(2*k+2) = sum(imgarr{k}(in).*xind)./sum(imgarr{k}(in));
            end
            res(2*k+2*(nch-1)+1) = mean(imgarr{k}(in));
            res(2*k+2*(nch-1)+2) = std(imgarr{k}(in));
            
        end
        if nwnz > 3;
            ysh = xind-res(2); % To match Brent's calculation
            xsh = yind-res(1);
            uxx = sum(xsh.^2)/nwnz;
            uyy = sum(ysh.^2)/nwnz;
            uxy = sum(xsh.*ysh)/nwnz;
            qrot = sqrt((uxx-uyy).^2+4*(uxy.^2));
            mjra = sqrt(2)*sqrt(uxx+uyy+qrot);
            mnra = sqrt(2)*sqrt(uxx+uyy-qrot);
            axrat = mjra/mnra;
            
            if isfinite(axrat) == 0
                axrat = 0;
            end
            res(ecstr) = axrat;
            
            if uyy>uxx
                num = uyy-uxx+sqrt((uyy-uxx).^2+4*uxy.^2);
                den = 2*uxy;
            else
                num = 2*uxy;
                den = uxx-uyy+sqrt((uyy-uxx).^2+4*uxy.^2);
            end
            
            if num == 0 || den == 0
                ori = 0;
            else
                ori = atan(num./den);
            end
            
            if isfinite(ori) == 0
                ori = 0;
            end
            res(orstr) = ori;
        else
            res(ecstr) = 0;
            res(orstr) = 0;
        end
        res(idstr) = mp;
        res(tstr) = i;
        
        sres = [sres ; res];
        for k = 1:nch-1
            for m = 1:nvecp
                starr(xind(m),yind(m),k) = res(2+2*(nch-1)+2*(k-1)+1);
            end
        end
    end
    for k = 1:nch-1
        name = fullfile(keywords.folder, ['avg_' imgn{i,k}]);
        imwrite2tif(starr(:,:,k),[],name,'single')
    end
end

tavg = zeros(nt,2*length(colvec)+2);
for i = 1:nt
    tavg(i,1) = i;
    wfr = find(sres(:,tstr) == i);
    nwfr = length(wfr);
    tavg(i,2*length(colvec)+2) = nwfr;
    for j = 1:nvec
        tavg(i,2*(j-1)+2) = mean(sres(wfr,colvec(j)));
        tavg(i,2*(j-1)+3) = std(sres(wfr,colvec(j)));
    end
end

name = keywords.outname;

tname = 'tavg_';
save(fullfile(keywords.folder,[tname name '.txt']),'tavg','-ascii')
save(fullfile(keywords.folder,['blb_anl_cent_' name '.txt']),'sres','-ascii')

end

function imgn = imgn_check(bases,folder)
results1 = file_search(bases{1},folder);
imgn = cell(length(results1),length(bases));
imgn(:,1) = results1;
for i = 2:length(bases)
    results = file_search(bases{i},folder);
    imgn(:,i) = results;
end
end

function imgarr = read_chnls(imgncol)
imgarr = cell(1,length(imgncol));
for i = 1:length(imgncol);
    imgarr{i} = double(imread(imgncol{i}));
end
end

