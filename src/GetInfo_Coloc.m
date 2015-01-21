function SaveParams = GetInfo_Coloc(folder)

% A program allowing for the manual input of all parameters
% for a Coloc experiment.

if isempty(file_search(['SaveParams_' folder '.mat'],folder)) % Manually input and save parameters used in the analysis

    SaveParams.folder = folder;
    SaveParams.num_exp = input('How many experimental groups do you have? ');
    SaveParams.exp_cell = cell(1,SaveParams.num_exp);
    for i = 1:SaveParams.num_exp
        SaveParams.exp_cell{i} = input('Enter an experimental group name \n(Ex. VinTS_Zyxin): ','s');
    end
    SaveParams.mag = input('What magnification were your images taken at (40x or 60x)? ','s');
    SaveParams.channel1 = input('What is your first channel? ','s');
    SaveParams.channel2 = input('What is your second channel? ','s');
    SaveParams.find_blobs = input('Would you like to find the blobs (y or n)? ','s');
    if strcmpi(SaveParams.find_blobs,'y')
        SaveParams.num_channel = 4;
        SaveParams.extra_bkg1 = input('What, if any, extra background (~100 is good for \nmost stains) would you like to subtract off channel 1 \nbefore FA-gen?:');
        SaveParams.extra_bkg2 = input('What, if any, extra background (~100 is good for \nmost stains) would you like to subtract off channel 2 \nbefore FA-gen?:');
        SaveParams.optimize1 = input('Would you like to optimize your channel 1 blob params \nwith ParameterSelector (y or n)?','s');
        SaveParams.optimize2 = input('Would you like to optimize your channel 2 blob params \nwith ParameterSelector (y or n)?','s');
        if strcmpi(SaveParams.optimize1,'n')
            SaveParams.blob_params1 = input('Manually input params for channel 1: ');
        elseif strcmpi(SaveParams.optimize1,'y')
            SaveParams.blob_params1 = input('Starting params for channel 1: ');
        end
        if strcmpi(SaveParams.optimize2,'n')
            SaveParams.blob_params2 = input('Manually input params for channel 2: ');
        elseif strcmpi(SaveParams.optimize2,'y')
            SaveParams.blob_params2 = input('Starting params for channel 2: ');
        end
        SaveParams.analyze_blobs = input('Would you like to analyze the blobs (y or n)? ','s');
    end
    if strcmpi(SaveParams.analyze_blobs,'y')
        SaveParams.reg_select = input('Would you like to select boundaries/regions \non your images (y or n)? ','s');
        if strcmpi(SaveParams.reg_select,'y');
            SaveParams.pre_exist = input('Do you want to use previously generated \npoly files (y or n)? ', 's');
            if strcmpi(SaveParams.pre_exist,'n');
                SaveParams.manual = input('Manually select cell boundaries (y or n)? ', 's');
                if strcmpi(SaveParams.manual,'y')
                    SaveParams.rat = 'N/A';
                elseif strcmpi(SaveParams.manual,'n')
                    SaveParams.rat = input('What threshold ratio would you like to use \nto select cells (~0.5 is good for PXNrb stains)?');
                end
            elseif strcmpi(SaveParams.pre_exist,'y')
                SaveParams.manual = 'y';
                SaveParams.rat = 'N/A';
            end
            SaveParams.reg_calc = input('Calculate region properties (size, eccentricity, y or n)? ', 's');
        end
    end
    save(fullfile(pwd,folder,['SaveParams_' folder '.mat']),'-struct','SaveParams');
    
else % Load the parameter file and save variables as the different parts of it
    SaveParams = load(['SaveParams_' folder '.mat']);
end

