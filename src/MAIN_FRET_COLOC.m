%% Set up
clear;
close all;
clc;
prefix = '';

%% Get Information
folder = input('Type the name of the folder that contains your images, \n make sure it is added to the path, \n and name your files so they look like \n"exp_01_w1Achannel.TIF" and "exp_01_w2FRETchannel.TIF",\n"exp_01_w3Dchannel.TIF" : ','s');
SaveParams = GetInfo_FRET_Coloc(folder);

%% If files are .lsm, convert to .TIF
rehash
if ~isempty(file_search('\w+.lsm',folder))
    for i = 1:SaveParams.num_exp
        lsm2tif1([SaveParams.exp_cell{i} '\w+.lsm'],folder,{SaveParams.Achannel, SaveParams.FRETchannel,SaveParams.Dchannel, SaveParams.Schannel});
    end
end

%% Preprocess images using PreParams.mat file in GoogleDrive (Protocols -> Analysis Protocols -> FRET)
rehash
if isempty(file_search('pre_\w+',folder))
    preprocess(fullfile(folder,'PreParams_60x_fixed.mat'),folder)
end
prefix = 'pre_';

%% Calculate Bleedthroughs
rehash

param.bit = 16;
param.width = 100;
param.avg = 50;
param.outname = [folder '_' prefix 'bleedthroughs'];
param.sourcefolder = folder;
param.destfolder = folder;

param.dthres = SaveParams.dthres;
param.athres = SaveParams.athres;

param.nobkgd = 1;
param.nozero = 0;
param.ocimg = 0;

if strcmpi(SaveParams.bt,'y') && isempty(file_search('bsa_\w+',folder))
    [SaveParams.abt,SaveParams.dbt] = fret_bledth([prefix SaveParams.donor_pre '\w+\d+\w+' SaveParams.Achannel '.TIF'],...
        [prefix SaveParams.donor_pre '\w+\d+\w+' SaveParams.Dchannel '.TIF'],...
        [prefix SaveParams.donor_pre '\w+\d+\w+' SaveParams.FRETchannel '.TIF'],...
        [prefix SaveParams.acceptor_pre '\w+\d+\w+' SaveParams.Achannel '.TIF'],...
        [prefix SaveParams.acceptor_pre '\w+\d+\w+' SaveParams.Dchannel '.TIF'],...
        [prefix SaveParams.acceptor_pre '\w+\d+\w+' SaveParams.FRETchannel '.TIF'],...
        param);
    save(fullfile(pwd,folder,['SaveParams_' folder '.mat']),'-struct','SaveParams');
end

%% Correct the Images
rehash
file = param.outname;
param.imin = [SaveParams.venus_thres 0 -10000];
param = rmfield(param,'outname');
param.donor_norm = 0;
param.double_norm = 0;
param.leave_neg = 1;
param.ocimg = 1;
if strcmpi(SaveParams.correct,'y') && isempty(file_search('cna_\w+.TIF',folder));
    for i = 1:length(SaveParams.exp_cell)
        fret_correct_efficiency(...
            [prefix SaveParams.exp_cell{i} '\w+\d+\w+' SaveParams.Achannel '.TIF'],...
            [prefix SaveParams.exp_cell{i} '\w+\d+\w+' SaveParams.Dchannel '.TIF'],...
            [prefix SaveParams.exp_cell{i} '\w+\d+\w+' SaveParams.FRETchannel '.TIF'],...
            SaveParams,param);
    end
end

%% Optimize FA params for Venus
rehash
if strcmpi(SaveParams.find_blobs,'y') && strcmpi(SaveParams.optimize,'y') && isempty(file_search('fa_\w+.TIF',folder))
    WidthRange = [0,100];
    ThreshRange = [0,10000];
    MergeRange = [0,100];
    ParameterValues = SaveParams.blob_params;
    ImageNameCell = file_search([prefix SaveParams.exp_cell{1} '\w+\d+\w+' SaveParams.blob_channel '.TIF'],folder);
    for i = 1:length(ImageNameCell);
        ImageName = ImageNameCell{i};
        Image = double(imread(ImageName));
        Values(i,:) = ParameterSelectorFunction(Image,WidthRange,ThreshRange,MergeRange,ParameterValues);
    end
    SaveParams.blob_params = round(mean(Values));
    save(fullfile(pwd,folder,['SaveParams_' folder '.mat']),'-struct','SaveParams');
end

%% Optimize FA params for each Stain channel
rehash
if strcmpi(SaveParams.find_blobs,'y') && isempty(file_search('fa_\w+Cy5.TIF',folder))
    WidthRange = [0,100];
    ThreshRange = [0,10000];
    MergeRange = [0,100];
    for i = 1:SaveParams.num_exp;
        StainParameterValues{i} = SaveParams.blob_params;
        StainImageNames = file_search([prefix SaveParams.exp_cell{i} '\w+\d+\w+' SaveParams.Schannel '.TIF'],folder);
        StainImageName = StainImageNames{1};
        StainImage = double(imread(StainImageName));
        StainValues{i} = ParameterSelectorFunction(StainImage,WidthRange,ThreshRange,MergeRange,StainParameterValues{i});
    end
    SaveParams.blob_params_stain = StainValues;
    save(fullfile(pwd,folder,['SaveParams_' folder '.mat']),'-struct','SaveParams');
end

%% Generate FA Masks on Venus channel
rehash
if strcmpi(SaveParams.find_blobs,'y') && isempty(file_search('fa_\w+',folder))
    for i = 1:SaveParams.num_exp
        fa_gen(['bsa_' prefix SaveParams.exp_cell{i} '\w+' SaveParams.blob_channel '.TIF'],SaveParams.blob_params,param.destfolder,SaveParams)
    end
end

%% Generate FA Masks on Stain channel
rehash
if strcmpi(SaveParams.find_blobs,'y') && isempty(file_search(['fa_\w+' SaveParams.Schannel '.TIF'],folder))
    for i = 1:SaveParams.num_exp
        fa_gen([prefix SaveParams.exp_cell{i} '\w+' SaveParams.Schannel '.TIF'],SaveParams.blob_params_stain{i},param.destfolder,SaveParams)
    end
end

%% Do additional local background subtraction to get rid of cytosolic signal in staining channel
rehash
if isempty(file_search('bslocal1_\w+.TIF',folder))
    for i = 1:SaveParams.num_exp
        local_bs(...
            [prefix SaveParams.exp_cell{i} '\w+\d+\w+' SaveParams.Schannel '.TIF'],...
            ['fa_' prefix SaveParams.exp_cell{i} '\w+\d+\w+' SaveParams.Schannel '.TIF'],...
            60,0.2,folder);
    end
end


%% Run Blob Analysis and Mask Images
rehash
if strcmpi(SaveParams.analyze_blobs,'y')
    for i = 1:SaveParams.num_exp
        keywords(i).sizemin = 8;
        keywords(i).sizemax = 10000;
        keywords(i).folder = param.destfolder;
        pre_outname1 = file_search([prefix SaveParams.exp_cell{i} '\w+' SaveParams.Achannel '.TIF'],folder);
        pre_outname2 = pre_outname1{1}(1:end-(10+length(SaveParams.Achannel)));
        keywords(i).outname = pre_outname2;
        keywords(i).maskchannel = SaveParams.Achannel;
        if length(file_search('blb_anl\w+.txt',folder)) < i
            blob_analyze_centroids(...
                {['cna_' prefix SaveParams.exp_cell{i} '\w+' SaveParams.FRETchannel '.TIF'],...
                ['eff_' prefix SaveParams.exp_cell{i} '\w+' SaveParams.FRETchannel '.TIF'],...
                ['dpa_' prefix SaveParams.exp_cell{i} '\w+' SaveParams.FRETchannel '.TIF'],...
                ['bsd_' prefix SaveParams.exp_cell{i} '\w+' SaveParams.Dchannel '.TIF'],...
                ['bsa_' prefix SaveParams.exp_cell{i} '\w+' SaveParams.Achannel '.TIF'],...
                [prefix SaveParams.exp_cell{i} '\w+' SaveParams.Schannel '.TIF'],...
                ['bslocal1_' prefix SaveParams.exp_cell{i} '\w+' SaveParams.Schannel '.TIF'],...
                ['fa_bsa_' prefix SaveParams.exp_cell{i} '\w+.TIF']},keywords(i))
        end
    end
end
rehash
if strcmpi(SaveParams.analyze_blobs,'y') && isempty(file_search('masked\w+.TIF',folder))
    for i = 1:SaveParams.num_exp
        app_mask(...
            {['cna_' prefix SaveParams.exp_cell{i} '\w+' SaveParams.FRETchannel '.TIF'],...
            ['eff_' prefix SaveParams.exp_cell{i} '\w+' SaveParams.FRETchannel '.TIF'],...
            ['dpa_' prefix SaveParams.exp_cell{i} '\w+' SaveParams.FRETchannel '.TIF'],...
            ['bsd_' prefix SaveParams.exp_cell{i} '\w+' SaveParams.Dchannel '.TIF'],...
            ['bsa_' prefix SaveParams.exp_cell{i} '\w+' SaveParams.Achannel '.TIF'],...
            [prefix SaveParams.exp_cell{i} '\w+' SaveParams.Schannel '.TIF'],...
            ['bslocal1_' prefix SaveParams.exp_cell{i} '\w+' SaveParams.Schannel '.TIF'],...
            ['fa_bsa_' prefix SaveParams.exp_cell{i} '\w+.TIF']},SaveParams,SaveParams.Achannel)
    end
end

%% Select Boundaries and calculate boundary properties
rehash
if strcmpi(SaveParams.reg_select,'y')
    for i = 1:SaveParams.num_exp
        newcols = boundary_dist([prefix SaveParams.exp_cell{i} '\w+\d+\w+' SaveParams.Schannel '.TIF'],...
            ['blb_anl_' keywords(i).outname '.txt'],...
            folder,...
            SaveParams.manual,...
            SaveParams.reg_calc,...
            SaveParams.rat,...
            SaveParams.pre_exist,...
            SaveParams.num_channel);
        rehash
        img_names = file_search([prefix SaveParams.exp_cell{i} '\w+\d+\w+' SaveParams.Schannel '.TIF'],folder);
        num_img = length(img_names);
        for j = 1:num_img
            mask_img(['polymask\w+' img_names{j}(1:end-4) '.png'],folder)
        end
        app_cols_blb(['blb_anl_' keywords(i).outname '.txt'],newcols,folder,SaveParams.num_channel)
    end
end