function app_mask_FRET(A, D, FRET, folder)

files = file_search('fa_\w+.TIF',folder);
for i = 1:length(files)
    m = double(imread(files{i}));
    m(m ~= 0) = 1;
    scores = strfind(files{i},'_');
    base = files{i}(4:scores(end));
    
    C1 = single(imread([base 'w1' A '.TIF']));
    mC1 = m.*C1;
    imwrite2tif(mC1,[],fullfile(folder,['masked_' base 'w1' A '.TIF']),'single')
    
    C2 = single(imread([base 'w2' FRET '.TIF']));
    mC2 = m.*C2;
    imwrite2tif(mC2,[],fullfile(folder,['masked_' base 'w2' FRET '.TIF']),'single')
    
    C3 = single(imread([base 'w3' D '.TIF']));
    mC3 = m.*C3;
    imwrite2tif(mC3,[],fullfile(folder,['masked_' base 'w3' D '.TIF']),'single')
end