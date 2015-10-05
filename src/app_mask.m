function app_mask(bases,maskchannel,folder)

% A function to apply a mask to different
% channels using a provided mask.
% Inputs:
%   bases - a cell array containing regular expressions representing each
%   image channel that you would like to mask separated by commas, with
%   the last one being the regular expression for the masks (can use the
%   results of fa_gen)
%   maskchannel - the channel that you have chosen to mask the images with
%   folder - name of the folder where images are contained
% Outputs:
%   masked images
%       A set of images beginning with masked_ that are the masked image
%       channels based on the last image in bases
% Sample Call:
%   SaveParams.folder = 'FRET_test';
%   app_mask_new({...
%                ['cna_' prefix SaveParams.exp_cell{i} '\w+' SaveParams.FRETchannel '.TIF'],...
%                 ['bsd_' prefix SaveParams.exp_cell{i} '\w+' SaveParams.Dchannel '.TIF'],...
%                 ['bsa_' prefix SaveParams.exp_cell{i} '\w+' SaveParams.Achannel '.TIF'],...
%                 ['fa_bsa_' prefix SaveParams.exp_cell{i} '\w+.TIF']},SaveParams)
%   This applies the masks of the form ['fa_bsa_' prefix SaveParams.exp_cell{i} '\w+.TIF'] to the
%   three image channels (CNA, BSD, BSA), all found in the folder 'FRET_test'. 
%   It will output masked images from the three input channels.
% Required Functions:
%   file_search
%   imwrite2tif
%
% This code 'app_mask' should be considered 'freeware' and may be
% distributed freely (outside of the military-industrial complex) in its
% original form when properly attributed.

imgn = imgn_check(bases,folder);
szn = size(imgn);
nch = szn(2);
nt = szn(1);

for i = 1:nt % for each image (nt = number of timepoints or images)
    imgarr = read_chnls(imgn(i,:));
    
    bimg = imgarr{nch}; % blob mask image
    bimg(bimg>0) = 1; % make blob mask image binary
    for j = 1:nch-1
        cimg = imgarr{j};
        cimg_masked = cimg.*bimg;
        name = fullfile(folder,'Masked Images',['masked_on_' maskchannel '_' imgn{i,j}]);
        imwrite2tif(cimg_masked,[],name,'single');
    end
end

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

