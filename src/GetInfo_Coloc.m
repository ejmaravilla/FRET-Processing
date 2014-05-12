function SaveParams = GetInfo_Coloc(folder)

% A program allowing for the manual input of all parameters
% for a Coloc experiment.

if isempty(file_search(['SaveParams_' folder '.mat'],folder)) % Manually input and save parameters used in the analysis
    
    SaveParams.num_exp = input('How many experimental groups do you have? ');
    SaveParams.exp_cell = cell(1,SaveParams.num_exp);
    for i = 1:SaveParams.num_exp
       SaveParams.exp_cell{i} = input('Enter an experimental group name \n(Ex. VinTS_Zyxin): ','s');
    end
    SaveParams.num_channel = 2;
    SaveParams.mag = input('What magnification were your images taken at (40x or 60x)? ','s');
    SaveParams.channel1 = input('What is your first channel? ','s');
    SaveParams.channel2 = input('What is your second channel? ','s');
    SaveParams.crop = input('Would you like to crop your images (y or n)? ','s');
    SaveParams.reg = input('Do you need to register your images (y or n)? ','s');
    SaveParams.shadecorrect = input('Shade correct (y or n)? ','s');
    if strcmpi(SaveParams.shadecorrect,'y');
        SaveParams.shade_pre = input('Enter shade correct image names (Ex. Shade): ','s');
    end
    SaveParams.find_blobs = input('Would you like to find the blobs (y or n)? ','s');
    if strcmpi(SaveParams.find_blobs,'y')
        SaveParams.blob_channel = input(['Which channel contains your FA marker stain? "' SaveParams.channel1 '"  or  "' SaveParams.channel2 '":  '],'s');
        SaveParams.extra_bkg = input('What, if any, extra background (~100 is good for \nmost stains) would you like to subtract off \nbefore FA-gen?:');
        SaveParams.optimize = input('Would you like to optimize your blob params \nwith ParameterSelector (y or n)?','s');
        if strcmpi(SaveParams.optimize,'n')
            SaveParams.blob_params = input('Manually input params: ');
        elseif strcmpi(SaveParams.optimize,'y')
            SaveParams.blob_params = input('Starting params: ');
        end
        SaveParams.analyze_blobs = input('Would you like to analyze the blobs (y or n)? ','s');
        if strcmpi(SaveParams.analyze_blobs,'y')
            SaveParams.reg_select = input('Would you like to select boundaries/regions \non your images (y or n)? ','s');
            if strcmpi(SaveParams.reg_select,'y');
                SaveParams.pre_exist = input('Do you want to use previously generated \npoly files (y or n)? ', 's');
                if strcmpi(SaveParams.pre_exist,'n');
                    SaveParams.manual = input('Manually select cell boundaries (y or n)? ', 's');
                    if strcmpi(SaveParams.manual,'y')
                        SaveParams.closed_open = input('Will your boundaries be "closed" or "open"? ','s');
                        SaveParams.rat = 'N/A';
                    elseif strcmpi(SaveParams.manual,'n')
                        SaveParams.rat = input('What threshold ratio would you like to use \nto select cells (~0.5 is good for PXNrb stains)?');
                        SaveParams.closed_open = 'closed';
                    end
                elseif strcmpi(SaveParams.pre_exist,'y')
                    SaveParams.manual = 'y';
                    SaveParams.closed_open = 'closed';
                    SaveParams.rat = 'N/A';
                end
                if strcmpi(SaveParams.closed_open, 'closed')
                    SaveParams.reg_calc = input('Calculate region properties (size, eccentricity, y or n)? ', 's');
                elseif strcmpi(SaveParams.closed_open, 'open')
                    SaveParams.reg_calc = 'n';
                end
            end
        end
    end
    save(fullfile(pwd,folder,['SaveParams_' folder '.mat']),'-struct','SaveParams');
    
else % Load the parameter file and save variables as the different parts of it
    SaveParams = load(['SaveParams_' folder '.mat']);
end

