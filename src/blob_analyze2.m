function blob_analyze2(bases,keywords)

imgn = imgn_check(bases,keywords.folder);

szn = size(imgn);
nch = szn(2);
nt = szn(1);
dims = size(double(imread(imgn{1,1})));

resind = 2+2*(nch-1);
szstr = resind+1;
ecstr = resind+2;
orstr = resind+3;
idstr = resind+4;
tstr = resind+5;

% NOT CORRECT INDEXING!!
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
        res(2) = sum(mcimg.*xind)/tb; % xind is actually columns, or y in traditional notation
        res(1) = sum(mcimg.*yind)/tb; % yind is actually rows, or x in traditional notation
        
        for k = 1:nch-1
            res(2*k+1) = mean(imgarr{k}(in));
            res(2*k+2) = std(imgarr{k}(in));
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
                starr(xind(m),yind(m),k) = res(2*k+1);
            end
        end
    end
    for k = 1:nch-1
        name = [keywords.folder '\avg_' imgn{i,k}];
        tagstruct.Photometric = 1;
        tagstruct.PlanarConfiguration = 1;
        tagstruct.Compression= 1;
        tagstruct.BitsPerSample = 32;
        tagstruct.SampleFormat = 3;
        tagstruct.ImageWidth = dims(2);
        tagstruct.ImageLength = dims(1);
        t = Tiff(name, 'w');
        t.setTag(tagstruct);
        t.write(single(starr(:,:,k)));
        t.close();
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
save([keywords.folder '\' tname name '.txt'],'tavg','-ascii')
save([keywords.folder '\blb_anl_' name '.txt'],'sres','-ascii')

end

function imgn = imgn_check(bases,folder)
results1 = file_search(bases{1},folder);
imgn = cell(length(results1),length(bases));
imgn(:,1) = results1';
for i = 2:length(bases)
    results = file_search(bases{i},folder);
    imgn(:,i) = results';
end
end

function imgarr = read_chnls(imgncol)
imgarr = cell(1,length(imgncol));
for i = 1:length(imgncol);
    imgarr{i} = double(imread(imgncol{i}));
end
end

