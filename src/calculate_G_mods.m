function calculate_G_mods(FRETpair,linker,n,date)
%Use the output from this code to calculate_G calculates the
%G-factor from donor (bsd) acceptor (bsa) and corrected FRET (cna)
%images based on analysis from Chen et al. Biophysical Journal 2006

%% Read in Pre-processing parameters

if (exist('folder','var'))
    [~,params_file] = GetParamsFile(folder); %%#ok<ASGLU>
else
    [folder,params_file] = GetParamsFile; %%#ok<ASGLU>
end
ProcessParamsFile;


%% Output data on bsd, bsa, cna, c, dpa from TSMod Data
% Calculations for first dataset
if strcmpi(FRETpair,'TV') || strcmpi(FRETpair,'tTV')
    bsd_names1 = file_search(['bsd_\w+' linker num2str(n) '_\w+_w3Teal.TIF'],folder);
    bsa_names1 = file_search(['bsa_\w+' linker num2str(n) '_\w+_w1Venus.TIF'],folder);
    cna_names1 = file_search(['cna_\w+' linker num2str(n) '_\w+_w2TVFRET.TIF'],folder);
    c_names1 = file_search(['c_\w+' linker num2str(n) '_\w+_w2TVFRET.TIF'],folder);
elseif strcmpi(FRETpair,'CR') || strcmpi(FRETpair,'tCR')
    bsd_names1 = file_search(['bsd_\w+' linker num2str(n) '_\w+_w3FWFITC.TIF'],folder);
    bsa_names1 = file_search(['bsa_\w+' linker num2str(n) '_\w+_w1FWTR.TIF'],folder);
    cna_names1 = file_search(['cna_\w+' linker num2str(n) '_\w+_w2CRFRET.TIF'],folder);
    c_names1 = file_search(['c_\w+' linker num2str(n) '_\w+_w2CRFRET.TIF'],folder);
end

% Pre-allocate matrix outdata1a and outdata1b
outdata1a = [1,1,1];
outdata1b = [1,1,1];
outdata1c = [1,1,1];
outdata1d = [1,1,1];
outdata1e = [1,1,1];

for i = 1:length(bsd_names1)
    % Load in images
    bsd_img1{i} = single(imread(fullfile(folder,'FRET Correct Images',bsd_names1{i})));
    bsa_img1{i} = single(imread(fullfile(folder,'FRET Correct Images',bsa_names1{i})));
    cna_img1{i} = single(imread(fullfile(folder,'FRET Correct Images',cna_names1{i})));
    c_img1{i} = single(imread(fullfile(folder,'FRET Correct Images',c_names1{i})));
    % Create donor per acceptor (dpa) images
    dpa_img1{i} = bsd_img1{i}./bsa_img1{i};
    dpa_img1{i}(isnan(dpa_img1{i}))=0;
    % Create mask based on FAs, donor, and acceptor images [500 60000] and manual cell
    % mask
    donormask1{i} = bsd_img1{i};
    donormask1{i}(donormask1{i}>60000) = 0;
    donormask1{i}(donormask1{i}>300) = 1;
    donormask1{i}(donormask1{i}~=1) = 0;
    acceptormask1{i} = bsa_img1{i};
    acceptormask1{i}(acceptormask1{i}>60000) = 0;
    acceptormask1{i}(acceptormask1{i}>500) = 1;
    acceptormask1{i}(acceptormask1{i}~=1) = 0;
    cnamask1{i} = cna_img1{i};
    cnamask1{i}(cnamask1{i}>2) = 0;
    cnamask1{i}(cnamask1{i}>0) = 1;
    dpamask1{i} = dpa_img1{i};
    dpamask1{i}(dpamask1{i}>4) = 0;
    dpamask1{i}(dpamask1{i}>0) = 1;
    
    pre_exist = 'y';
    
    if strcmpi(pre_exist,'n')
        % Manual cell masking
        [im_w, im_h] = size(bsa_img1{i});
        figure; imagesc(bsa_img1{i},[0 10000]);
        cell_num = input('how many cells would you like to select?');
        cells = zeros(1948,1948);
        for k = 1:cell_num
            v = 1;
            while v == 1;
                M = imfreehand(gca);
                v = input('Keep region (1 = no, anything = yes)?');
            end
            P0 = M.getPosition;
            D = round([0; cumsum(sum(abs(diff(P0)),2))]);
            P = interp1(D,P0,D(1):.5:D(end));
            mask1 = poly2mask(P(:,1), P(:,2), im_w, im_h);
            mask = mat2gray(mask1);
            mask = mask./(2^8);
            imwrite(mask,fullfile(folder,['polymask_cell' num2str(k) '_' bsa_names1{i}(1:end-4) '.png']));
            rehash
            cells = cells + mask.*k;
        end
        cells = im2uint8(cells);
        imwrite(cells,fullfile(folder,['polymask_cells_' bsa_names1{i}(1:end-4) '.png']));
    elseif strcmpi(pre_exist,'y')
        %         Read in old cell masks
        if ~isempty(file_search('\w+Cy5.TIF',folder))
            cell_names = file_search('pre\w+Cy5.TIF',folder);
            polycells = imread(fullfile(folder,'Cell Mask Images',['polymask_cells_' cell_names{i}(1:end-4) '.png']));
        else
            polycells = imread(fullfile(folder,'Cell Mask Images',['polymask_cells_' bsa_names1{i}(1:end-4) '.png']));
        end
        cells = bwlabel(polycells);
    end
    % Apply mask to donor, acceptor, and corrected FRET images (also get
    % rid of zeros in other channels, cna values > 1 and dpa values > 1)
    
    % Label each blob with 8-connectivity, so we can make measurements of it
    % and get rid of small cells, save out masks and .dat files with
    % coordinates to find in blob_file.
    for j = 1:max(cells(:))
        mask1 = cells == j;
        mask1(mask1>0) = 1;
        mask = mat2gray(mask1);
        %         imwrite2tif(mask,[],fullfile(folder,['polymask_cell' num2str(j) '_' bsa_names1{i}]),'single');
        %         mask1 = imread(fullfile(folder,['polymask_cell' num2str(j) '_' bsa_names1{i}]));
        bsd_img_masked1{i,j} = mask1.*donormask1{i}.*acceptormask1{i}.*cnamask1{i}.*dpamask1{i}.*bsd_img1{i};
        bsd_img_masked1{i,j}(isnan(bsd_img_masked1{i,j})) = 0;
        bsa_img_masked1{i,j} = mask1.*donormask1{i}.*acceptormask1{i}.*cnamask1{i}.*dpamask1{i}.*bsa_img1{i};
        bsa_img_masked1{i,j}(isnan(bsa_img_masked1{i,j})) = 0;
        cna_img_masked1{i,j} = mask1.*donormask1{i}.*acceptormask1{i}.*cnamask1{i}.*dpamask1{i}.*cna_img1{i};
        cna_img_masked1{i,j}(isnan(cna_img_masked1{i,j})) = 0;
        c_img_masked1{i,j} = mask1.*donormask1{i}.*acceptormask1{i}.*cnamask1{i}.*dpamask1{i}.*c_img1{i};
        c_img_masked1{i,j}(isnan(c_img_masked1{i,j})) = 0;
        dpa_img_masked1{i,j} = mask1.*donormask1{i}.*acceptormask1{i}.*cnamask1{i}.*dpamask1{i}.*dpa_img1{i};
        dpa_img_masked1{i,j}(isnan(dpa_img_masked1{i,j})) = 0;
        
        % Calculate things you need to calculate G
        a1 = median(nonzeros(cna_img_masked1{i,j}));
        a1(:,2) = i;
        a1(:,3) = j;
        b1 = median(nonzeros(dpa_img_masked1{i,j}));
        b1(:,2) = i;
        b1(:,3) = j;
        c1 = median(nonzeros(bsd_img_masked1{i,j}));
        c1(:,2) = i;
        c1(:,3) = j;
        d1 = median(nonzeros(bsa_img_masked1{i,j}));
        d1(:,2) = i;
        d1(:,3) = j;
        e1 = median(nonzeros(c_img_masked1{i,j}));
        e1(:,2) = i;
        e1(:,3) = j;
        outdata1a = vertcat(outdata1a,a1);
        outdata1b = vertcat(outdata1b,b1);
        outdata1c = vertcat(outdata1c,c1);
        outdata1d = vertcat(outdata1d,d1);
        outdata1e = vertcat(outdata1e,e1);
    end
    % Apply a variety of pseudo-colors to the regions and show user what the
    % cell outliner did
    close all
    % Write out tif of cells (grayscale, not rgb)
    %     imwrite2tif(cells,[],fullfile(folder,['polymask_cells_' bsa_names1{i}]),'single');
end
outdata1 = horzcat(outdata1a(2:end,1),outdata1b(2:end,1),outdata1c(2:end,1),outdata1d(2:end,1),outdata1e(2:end,:)); % Stick a number at the end for image number
outdata1 = double(outdata1);
outdata1(:,8) = (outdata1(:,5)./G)./(outdata1(:,3)+(outdata1(:,5)./G)); % estimated FRET efficiency
outdata1(:,9) = (outdata1(:,3)+(outdata1(:,5)./G))./(k.*outdata1(:,4)); % estimated Donor per acceptor
save(fullfile(folder,['ModData_' FRETpair '_' linker num2str(n) '.txt']),'outdata1','-ascii')
headers = {'CNA'...
    'Idd/Iaa'...
    'Idd'...
    'Iaa'...
    'C'...
    'Image ID'...
    'Cell ID'...
    'FRET Efficiency (%) estimate'...
    '[D]/[A] Estimate'...
    'FRET Pair'...
    'Linker'...
    'n'...
    'Linker Length (AAs)'...
    'Date'};
outdata1 = num2cell(outdata1);
[ncells,~] = size(outdata1);
FRETpairText = repmat(cellstr(FRETpair),ncells,1);
linkerText = repmat(cellstr(linker),ncells,1);
nText = num2cell(repmat(n,ncells,1));
dateText = repmat(cellstr(date),ncells,1);
if strcmpi(FRETpair,'tTV') || strcmpi(FRETpair,'tCR')
    if strcmpi(linker,'GGS')
        LinkerLengthText = num2cell(repmat(6*n,ncells,1));
    else
        LinkerLengthText = num2cell(repmat(5*n,ncells,1));
    end
elseif strcmpi(FRETpair,'TV') || strcmpi(FRETpair,'CR')
    if strcmpi(linker,'GGS')
        LinkerLengthText = num2cell(repmat(6*n + 13,ncells,1));
    else
        LinkerLengthText = num2cell(repmat(5*n + 13,ncells,1));
    end
end
outdata1 = horzcat(outdata1,FRETpairText,linkerText,nText,LinkerLengthText,dateText);
outdata1 = vertcat(headers,outdata1);
xlswrite(fullfile(folder,['ModData_headers_' date '_' FRETpair '_' linker num2str(n) '.xlsx']),outdata1)
rmpath(folder);
