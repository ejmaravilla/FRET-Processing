function app_mask_FRET_COLOC_localbs(A, D, FRET, S, folder)

files = file_search('fa_\w+.TIF',folder);
for i = 1:length(files)
    m = double(imread(files{i}));
    m(m ~= 0) = 1;
    scores = strfind(files{i},'_');
    base = files{i}(8:scores(end));
    
    C1 = single(imread(['bsa_' base 'w1' A '.TIF']));
    mC1 = m.*C1;
    imwrite2tif(mC1,[],fullfile(folder,['masked_bsa_' base 'w1' A '.TIF']),'single')
    
    C2 = single(imread(['cna_' base 'w2' FRET '.TIF']));
    mC2 = m.*C2;
    imwrite2tif(mC2,[],fullfile(folder,['masked_cna_' base 'w2' FRET '.TIF']),'single')
    
    C3 = single(imread(['bsd_' base 'w3' D '.TIF']));
    mC3 = m.*C3;
    imwrite2tif(mC3,[],fullfile(folder,['masked_bsd_' base 'w3' D '.TIF']),'single')
    
    C4 = single(imread([base 'w4' S '.TIF']));
    mC4 = m.*C4;
    imwrite2tif(mC4,[],fullfile(folder,['masked_' base 'w4' S '.TIF']),'single')
    
    C5 = single(imread(['bslocal1_' base 'w4' S '.TIF']));
    mC4 = m.*C4;
    imwrite2tif(mC4,[],fullfile(folder,['masked_bslocal1_' base 'w4' S '.TIF']),'single')
end