function app_mask(folder)

files = file_search('fa_\w+.TIF',folder);
for i = 1:length(files)
    m = double(imread(files{i}));
    m(m ~= 0) = 1;
    scores = strfind(files{i},'_');
    base = files{i}(8:scores(end));
    cna = single(imread(['cna_' base 'w2TVFRET.TIF']));
    mcna = m.*cna;
    imwrite2tif(mcna,[],fullfile(folder,['cna_masked_' base 'w2TVFRET.TIF']),'single')
    bsa = single(imread(['bsa_' base 'w1Venus.TIF']));
    mbsa = m.*bsa;
    imwrite2tif(mbsa,[],fullfile(folder,['bsa_masked_' base 'w1Venus.TIF']),'single')
    bsd = single(imread(['bsd_' base 'w3Teal.TIF']));
    mbsd = m.*bsd;
    imwrite2tif(mbsd,[],fullfile(folder,['bsd_masked_' base 'w3Teal.TIF']),'single')
end
