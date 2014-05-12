function app_mask_Coloc(channel1, channel2, folder)

files = file_search('fa_\w+.TIF',folder);
for i = 1:length(files)
    m = double(imread(files{i}));
    m(m ~= 0) = 1;
    scores = strfind(files{i},'_');
    base = files{i}(4:scores(end));
    C1 = single(imread([base 'w1' channel1 '.TIF']));
    mC1 = m.*C1;
    imwrite2tif(mC1,[],fullfile(folder,['masked_' base 'w1' channel1 '.TIF']),'single')
    C2 = single(imread([base 'w2' channel2 '.TIF']));
    mC2 = m.*C2;
    imwrite2tif(mC2,[],fullfile(folder,['masked_' base 'w2' channel2 '.TIF']),'single')
end