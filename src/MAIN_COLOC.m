%% Set up
clear;
close all;
clc;
prefix = '';

%% Get Information
folder = input('Type the name of the folder that contains your images, \n make sure it is added to the path, \n and name your files so they look like \n"exp_01_w1channel1.TIF" and "exp_01_w2channel2.TIF" : ','s');
SaveParams = GetInfo_Coloc(folder);

%% Preprocess images using PreParams.mat file in GoogleDrive (Protocols -> Analysis Protocols -> FRET)
rehash
if isempty(file_search('pre_\w+',folder))
    preprocess(fullfile(folder,'PreParams_60x_fixed.mat'),folder)
end
prefix = 'pre_';

%% Optimize FA params for channel 1 FAs or AJs
rehash
if strcmpi(SaveParams.find_blobs,'y') && strcmpi(SaveParams.optimize1,'y') && isempty(file_search(['fa_\w+' SaveParams.channel1 '.TIF'],folder))
    WidthRange = [0,100];
    ThreshRange = [0,10000];
    MergeRange = [0,100];
    ParameterValues = SaveParams.blob_params1;
    ImageNameCell = file_search([prefix SaveParams.exp_cell{1} '\w+\d+\w+' SaveParams.channel1 '.TIF'],folder);
    for i = 1:length(ImageNameCell);
        ImageName = ImageNameCell{i};
        Image = double(imread(ImageName));
        Values(i,:) = ParameterSelectorFunction(Image,WidthRange,ThreshRange,MergeRange,ParameterValues);
    end
    SaveParams.blob_params1 = round(mean(Values));
    save(fullfile(pwd,folder,['SaveParams_' folder '.mat']),'-struct','SaveParams');
end

%% Optimize FA params for channel 2 FAs or AJs
rehash
if strcmpi(SaveParams.find_blobs,'y') && strcmpi(SaveParams.optimize2,'y') && isempty(file_search(['fa_\w+' SaveParams.channel2 '.TIF'],folder))
    WidthRange = [0,100];
    ThreshRange = [0,10000];
    MergeRange = [0,100];
    ParameterValues = SaveParams.blob_params2;
    ImageNameCell = file_search([prefix SaveParams.exp_cell{1} '\w+\d+\w+' SaveParams.channel2 '.TIF'],folder);
    for i = 1:length(ImageNameCell);
        ImageName = ImageNameCell{i};
        Image = double(imread(ImageName));
        Values(i,:) = ParameterSelectorFunction(Image,WidthRange,ThreshRange,MergeRange,ParameterValues);
    end
    SaveParams.blob_params2 = round(mean(Values));
    save(fullfile(pwd,folder,['SaveParams_' folder '.mat']),'-struct','SaveParams');
end

%% Generate FA Masks on both channels
rehash
if strcmpi(SaveParams.find_blobs,'y') && isempty(file_search(['fa_\w+.TIF'],folder))
    for i = 1:SaveParams.num_exp
        fa_gen([prefix SaveParams.exp_cell{i} '\w+' SaveParams.channel1 '.TIF'],SaveParams.blob_params1,folder,SaveParams)
        fa_gen([prefix SaveParams.exp_cell{i} '\w+' SaveParams.channel2 '.TIF'],SaveParams.blob_params2,folder,SaveParams)
    end
end

%% Do additional local background subtraction to get rid of cytosolic signal in both channels
rehash
for i = 1:SaveParams.num_exp
    local_bs(...
        [prefix SaveParams.exp_cell{i} '\w+\d+\w+' SaveParams.channel1 '.TIF'],...
        ['fa_' prefix SaveParams.exp_cell{i} '\w+\d+\w+' SaveParams.channel1 '.TIF'],...
        60,0.2,folder);
    local_bs(...
        [prefix SaveParams.exp_cell{i} '\w+\d+\w+' SaveParams.channel2 '.TIF'],...
        ['fa_' prefix SaveParams.exp_cell{i} '\w+\d+\w+' SaveParams.channel2 '.TIF'],...
        60,0.2,folder);
end

%% Run Blob Analysis and Mask Images
rehash
if strcmpi(SaveParams.analyze_blobs,'y')
    for i = 1:SaveParams.num_exp
        keywords1(i).sizemin = 0;
        keywords1(i).sizemax = 10000;
        keywords1(i).folder = folder;
        pre1_outname1 = file_search([prefix SaveParams.exp_cell{i} '\w+' SaveParams.channel1 '.TIF'],folder);
        pre1_outname2 = pre1_outname1{1}(1:end-(10+length(SaveParams.channel1)));
        keywords1(i).outname = [pre1_outname2 '_FAgen_on_' SaveParams.channel1];
        keywords1(i).maskchannel = SaveParams.channel1;
        
        keywords2(i).sizemin = 0;
        keywords2(i).sizemax = 10000;
        keywords2(i).folder = folder;
        pre2_outname1 = file_search([prefix SaveParams.exp_cell{i} '\w+' SaveParams.channel2 '.TIF'],folder);
        pre2_outname2 = pre2_outname1{1}(1:end-(10+length(SaveParams.channel1)));
        keywords2(i).outname = [pre2_outname2 '_FAgen_on_' SaveParams.channel2];
        keywords2(i).maskchannel = SaveParams.channel2;
        
        if length(file_search(['blb_anl\w+' SaveParams.channel1 '.txt'],folder)) < i
            blob_analyze(...
                {[prefix SaveParams.exp_cell{i} '\w+' SaveParams.channel1 '.TIF'],...
                ['bslocal1_' prefix SaveParams.exp_cell{i} '\w+' SaveParams.channel1 '.TIF'],...
                [prefix SaveParams.exp_cell{i} '\w+' SaveParams.channel2 '.TIF'],...
                ['bslocal1_' prefix SaveParams.exp_cell{i} '\w+' SaveParams.channel2 '.TIF'],...
                ['fa_' prefix SaveParams.exp_cell{i} '\w+' SaveParams.channel1 '.TIF']},...
                keywords1(i))
            blob_analyze(...
                {[prefix SaveParams.exp_cell{i} '\w+' SaveParams.channel1 '.TIF'],...
                ['bslocal1_' prefix SaveParams.exp_cell{i} '\w+' SaveParams.channel1 '.TIF'],...
                [prefix SaveParams.exp_cell{i} '\w+' SaveParams.channel2 '.TIF'],...
                ['bslocal1_' prefix SaveParams.exp_cell{i} '\w+' SaveParams.channel2 '.TIF'],...
                ['fa_' prefix SaveParams.exp_cell{i} '\w+' SaveParams.channel2 '.TIF']},...
                keywords2(i))
        end
    end
end
rehash
if strcmpi(SaveParams.analyze_blobs,'y') && isempty(file_search('masked\w+.TIF',folder))
    for i = 1:SaveParams.num_exp
        app_mask(...
            {[prefix SaveParams.exp_cell{i} '\w+' SaveParams.channel1 '.TIF'],...
            ['bslocal1_' prefix SaveParams.exp_cell{i} '\w+' SaveParams.channel1 '.TIF'],...
            [prefix SaveParams.exp_cell{i} '\w+' SaveParams.channel2 '.TIF'],...
            ['bslocal1_' prefix SaveParams.exp_cell{i} '\w+' SaveParams.channel2 '.TIF'],...
            ['fa_' prefix SaveParams.exp_cell{i} '\w+' SaveParams.channel1 '.TIF']}...
            ,SaveParams,SaveParams.channel1)
        app_mask(...
            {[prefix SaveParams.exp_cell{i} '\w+' SaveParams.channel1 '.TIF'],...
            ['bslocal1_' prefix SaveParams.exp_cell{i} '\w+' SaveParams.channel1 '.TIF'],...
            [prefix SaveParams.exp_cell{i} '\w+' SaveParams.channel2 '.TIF'],...
            ['bslocal1_' prefix SaveParams.exp_cell{i} '\w+' SaveParams.channel2 '.TIF'],...
            ['fa_' prefix SaveParams.exp_cell{i} '\w+' SaveParams.channel2 '.TIF']}...
            ,SaveParams,SaveParams.channel2)
    end
end

%% Select Boundaries and calculate boundary properties
rehash
if strcmpi(SaveParams.reg_select,'y')
    for i = 1:SaveParams.num_exp
        newcols = boundary_dist(...
            [prefix SaveParams.exp_cell{i} '\w+\d+\w+' SaveParams.channel1 '.TIF'],...
            ['blb_anl_' keywords1(i).outname '.txt'],...
            folder,...
            SaveParams.manual,...
            SaveParams.reg_calc,...
            SaveParams.rat,...
            SaveParams.pre_exist,...
            SaveParams.num_channel);
        rehash
        img_names = file_search([prefix SaveParams.exp_cell{i} '\w+\d+\w+' SaveParams.channel1 '.TIF'],folder);
        num_img = length(img_names);
        for j = 1:num_img
            mask_img(['polymask\w+' img_names{j}],folder)
        end
        app_cols_blb(['blb_anl_' keywords1(i).outname '.txt'],newcols,folder,SaveParams.num_channel)
    end
    for i = 1:SaveParams.num_exp
        newcols = boundary_dist(...
            [prefix SaveParams.exp_cell{i} '\w+\d+\w+' SaveParams.channel1 '.TIF'],...
            ['blb_anl_' keywords2(i).outname '.txt'],...
            folder,...
            SaveParams.manual,...
            SaveParams.reg_calc,...
            SaveParams.rat,...
            'y',...
            SaveParams.num_channel);
        rehash
        img_names = file_search([prefix SaveParams.exp_cell{i} '\w+\d+\w+' SaveParams.channel1 '.TIF'],folder);
        num_img = length(img_names);
        for j = 1:num_img
            mask_img(['polymask\w+' img_names{j}],folder)
        end
        app_cols_blb(['blb_anl_' keywords2(i).outname '.txt'],newcols,folder,SaveParams.num_channel)
    end
end