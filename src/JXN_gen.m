function JXN_gen(aexp,folder)

afiles = file_search(aexp,folder);

high_pass_filt_width = 35;
thresh = 300;

for i = 1:length(afiles)
    imOrig = double(imread(afiles{i}));
    [r,c] = size(imOrig);
    AvgFilt = fspecial('average',high_pass_filt_width);
    pImg = padarray(imOrig,[high_pass_filt_width high_pass_filt_width],'symmetric');
    pSmImg = conv2(pImg,AvgFilt,'same');
    SmImg = pSmImg(1+high_pass_filt_width:r+high_pass_filt_width,1+high_pass_filt_width:c+high_pass_filt_width);
    FiltImg = double(imOrig) - SmImg;
    subplot(1,2,1);imagesc(imOrig)
    while ~isempty(thresh)
        im = FiltImg.*(FiltImg > thresh);
        mask = im;
        mask(mask>0) = 1;
        subplot(1,2,2); imagesc(mask)
        thresh = input('Enter new threshold or press Enter: ');
    end
    close;
    thresh = 300;
    imwrite2tif(mask,[],fullfile(folder,'JXN Images',['JXN_' afiles{i}]),'single');
end