function col_labels = blob_analyze(bases,FRETeff,sizemin,sizemax,outname,maskchannel,folder)

% A function to analyze the same blobs across images from different
% channels using a provided mask.
% Inputs:
%   bases - a cell array containing regular expressions representing each
%   image channel that you would like to analyze separated by commas, with
%   the last one being the regular expression for the masks (can use the
%   results of fa_gen)
%   FRETeff - indicates whether FRET efficiency was calculated previously
%   sizemin - minimum acceptable size for a structure in a mask
%   sizemax - maximum acceptable size for a structure in a mask
%   outname - name of the output file containing the data for each structure
%   maskchannel - channel in which masks were generated
%   folder - name of the folder containing the images
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
%   blb excel file
%       An .xlsx file containing all of the data from the blb file, but
%       with column headers that describe the contents of each column
%   col_labels
%       Cell array containing a list of the column headers from the blb
%       excel file.
%   avg images
%       A set of images beginning with avg_ that are the masked input
%       images with the values contained in each blob averaged together to
%       create a mean intensity for each blob.
% Sample Call:
%   blob_analyze({'Vinculin_\d+_w1FW FITC.TIF','Talin_\d+_w2FW Cy5.TIF','Paxillin_\d+_w3FW TR.TIF','fa_Vinculin_\d+_w1FW FITC.TIF'},'n',8,5000,'VTP Stain 101513','FITC','Stain 101513')
%   This applies the masks of the form fa_Vinculin_\d+_w1FW FITC.TIF to the
%   three image channels (Vinculin, Talin, Paxillin), all found in the
%   folder Stain 101513. It only looks at blobs of 8<size<5000. It will
%   output the text file: blb_anl_VTP Stain 101513.txt, and excel file:
%   blb_anl_labels_VTP Stain 101513.xlsx, along with a set of images starting with avg_
% Required Functions:
%   file_search
%   imwrite2tif
%
% This code 'blob_analyze' should be considered 'freeware' and may be
% distributed freely (outside of the military-industrial complex) in its
% original form when properly attributed.

imgn = imgn_check(bases,folder);

szn = size(imgn);
nch = szn(2);
nt = szn(1);
dims = size(double(imread(imgn{1,1})));

resind = 4*(nch-1)+2;
if strcmpi(FRETeff,'y')
    resind = resind + 1;
end

szstr = resind+1;
ecstr = resind+2;
orstr = resind+3;
idstr = resind+4;
tstr = resind+5;

res = zeros(1,resind+5);
col_labels = cell(1,resind+5);
sres = [];

if strcmpi(FRETeff,'y')
    lookup = load('freteff_force_lookup.txt');
end

for i = 1:nt
    starr = zeros(dims(1),dims(2),nch-1);
    imgarr = read_chnls(imgn(i,:));
    bimg = imgarr{nch}; % blob mask image
    
    sbimg = sort(bimg(:));
    [~,u] = unique(sbimg);
    u = [u;numel(sbimg)];
    del = u-circshift(u,1);
    wbe = find(del > sizemin & del < sizemax); % find large enough blobs
    wbe = wbe-1;
    lim = length(wbe);
    
    for j = 1:lim
        mp = sbimg(u(wbe(j)));
        in = find(bimg == mp);
        nwnz = length(in);
        res(szstr) = nwnz;
        if i == 1
            col_labels{szstr} = 'Blob Area';
            col_labels{ecstr} = 'Blob Axis Ratio';
            col_labels{orstr} = 'Blob Orientation';
            col_labels{idstr} = 'Blob ID';
            col_labels{tstr} = 'Image ID';
        end
        
        [xind,yind] = ind2sub(dims,in);
        nvecp = length(xind);
        
        res(2) = sum(xind)./length(xind);
        res(1) = sum(yind)./length(yind);
        if i == 1
            col_labels{2} = 'Geo Y';
            col_labels{1} = 'Geo X';
        end
        
        for k = 1:nch-1
            if isempty(strfind(bases{k},'cna')) || isempty(strfind(bases{k},'eff'))
                calcimg = 1./imgarr{k}(in);
            else
                calcimg = imgarr{k}(in);
            end
            res(2*k+1) = sum(calcimg.*yind)./sum(calcimg);
            res(2*k+2) = sum(calcimg.*xind)./sum(calcimg);
            res(2*(nch-1)+2*(k-1)+3) = mean(imgarr{k}(in));
            res(2*(nch-1)+2*(k-1)+4) = std(imgarr{k}(in));
            if i == 1
                col_labels{2*k+1} = [bases{k}(1:3) ' X'];
                col_labels{2*k+2} = [bases{k}(1:3) ' Y'];
                col_labels{2*(nch-1)+2*(k-1)+3} = [bases{k}(1:3) ' Mean'];
                col_labels{2*(nch-1)+2*(k-1)+4} = [bases{k}(1:3) ' STD'];
            end
            if k == nch-1 && strcmpi(FRETeff,'y')
                effs = res(2*(nch-1)+2*(k-1)+4);
                forces = zeros(1,length(effs));
                for m = 1:length(effs)
                    if effs(m) < min(lookup(:,1))
                        effs(m) = min(lookup(:,1));
                    elseif effs(m) > max(lookup(:,1))
                        effs(m) = max(lookup(:,1));
                    end
                    forces(m) = lookup(round(effs(m),4) == lookup(:,1),2);
                end
                res(2*(nch-1)+2*(k-1)+5) = forces;
                if i == 1
                    col_labels{2*(nch-1)+2*(k-1)+5} = 'Force';
                end
            end
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
        for k = 1:nch-1 % adjust to calculate avg image
            for m = 1:nvecp
                starr(xind(m),yind(m),k) = res(2*(nch-1)+2*(k-1)+3);
            end
            if k == nch-1
                for m = 1:nvecp
                    starr(xind(m),yind(m),k+1) = res(2*(nch-1)+2*(k-1)+5);
                end
            end
        end
    end
    for k = 1:nch-1
        name = fullfile(folder,'Average Images',['avg_on_' maskchannel '_' imgn{i,k}]);
        imwrite2tif(starr(:,:,k),[],name,'single')
        if k == nch-1 && strcmp('FRETeff','y')
            name = fullfile(folder,'Average Images',['avg_on_' maskchannel '_force_' imgn{i,k}]);
            imwrite2tif(starr(:,:,k+1),[],name,'single')
        end
    end
end

name = outname;
save(fullfile(folder,['blb_anl_' name '.txt']),'sres','-ascii')

cell_final_data = num2cell(sres);
cell_final_file = [col_labels; cell_final_data];
xlswrite(fullfile(folder,['blb_anl_labels_' name '.xlsx']),cell_final_file)

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

