function fa_gen(fname,params,fold,SaveParams)

% A simple program to generate masks using the water program
% A typical set of params is [25,1000,25]. If you input a bkg intensity, it
% will be subtracted off all images before fa_gen

files = file_search(fname,fold);

for i = 1:length(files)
    img = double(imread(files{i}));
% Only performs background subtraction on non-Venus channels
    if isfield(SaveParams,'bkg') && isempty(strfind(files{i},'Venus'))
        img = (img-SaveParams.bkg);
        img(img < 0) = 0;
    elseif isfield(SaveParams,'bkg1') && isempty(strfind(files{i},'Venus'))
        img = (img - SaveParams.bkg1);
        img(img < 0) = 0;
    elseif isfield(SaveParams,'bkg2') && isempty(strfind(files{i},'Venus'))
        img = (img - SaveParams.bkg2);
        img(img < 0) = 0;
    end
    % Resume water on possibly background subtracted image
    w = water(img,params);
    imwrite2tif(w,[],fullfile(fold,['fa_' files{i}]),'single');
end

end