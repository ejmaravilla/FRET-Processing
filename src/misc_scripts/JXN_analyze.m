function JXN_analyze(bases,FRETeff,outname,folder)

imgn = imgn_check(bases,folder);
szn = size(imgn);
nch = szn(2);
nt = szn(1);
dims = size(double(imread(imgn{1,1})));

resind = (nch-1)+2;
if strcmpi(FRETeff,'y')
    resind = resind + 1;
end
tstr = resind+1;

res = zeros(1,resind+1);
col_labels = cell(1,resind+1);
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
        if i == 1
            col_labels{tstr} = 'Image ID';
        end
        
        [xind,yind] = ind2sub(dims,in);
        
        res(2) = xind;
        res(1) = yind;
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
            res(k+2) = imgarr{k}(in);
            if i == 1
                col_labels{k+2} = [bases{k}(1:3) ' Mean'];
            end
            if k == nch-1 && strcmpi(FRETeff,'y')
                effs = res(k+2);
                forces = zeros(1,length(effs));
                for m = 1:length(effs)
                    if effs(m) < min(lookup(:,1))
                        effs(m) = min(lookup(:,1));
                    elseif effs(m) > max(lookup(:,1))
                        effs(m) = max(lookup(:,1));
                    end
                    forces(m) = lookup(round(effs(m),4) == lookup(:,1),2);
                end
                res(k+3) = forces;
                if i == 1
                    col_labels{k+3} = 'Force';
                end
            end
        end
        
        res(tstr) = i;
        sres = [sres ; res];
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