folder = input('Enter full path of folder: ','s');
addpath(genpath(folder))
expname = input('Enter experimental name: ','s');

fa_files = file_search(['fa_bsa_pre_' expname '_\d+_w1Venus.TIF'],folder);
dpa_files = file_search(['dpa_pre_' expname '_\d+_w2TVFRET.TIF'],folder);
eff_files = file_search(['eff_pre_' expname '_\d+_w2TVFRET.TIF'],folder);
cell_files = file_search(['polymask_cells_bsa_pre_' expname '_\d+_w1Venus.png'],folder);

data = zeros(length(eff_files),4);
count = 0;

for i = 1:length(eff_files)
    cell_img = single(imread(cell_files{i}));
    u = unique(cell_img(cell_img>0));
    eff_img = single(imread(eff_files{i}));
    fa_img = single(imread(fa_files{i}));
    dpa_img = single(imread(dpa_files{i}));
    invfa_img = imcomplement(logical(fa_img));
    maskeff_img = eff_img.*invfa_img;
    for j = 1:length(u)
        count = count + 1;
        subcell_img = cell_img;
        subcell_img(subcell_img ~= j) = 0;
        cellmaskeff_img = maskeff_img.*subcell_img;
        ind1 = cellmaskeff_img > 0;
        ind2 = dpa_img > 0.5 & dpa_img < 1.5;
        meff = mean(cellmaskeff_img(ind1 & ind2));
        n = length(cellmaskeff_img(ind1 & ind2));
        data(count,1) = i;
        data(count,2) = j;
        data(count,3) = meff;
        data(count,4) = n;
    end
end

save(fullfile(folder,['cytofret_' expname '.txt']),'data','-ascii')
rmpath(genpath(folder))