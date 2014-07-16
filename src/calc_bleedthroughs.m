function calc_bleedthroughs(folder,varargin)
tic;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Setup and Verify Inputs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_p = inputParser;
i_p.addRequired('folder',@(x)exist(x,'dir') == 7);

i_p.addParamValue('bitdepth',16,@(x)isnumeric(x) & x > 0);
i_p.addParamValue('width',100,@(x)isnumeric(x) & x > 0);
i_p.addParamValue('avg',50,@(x)isnumeric(x) & x > 0);

i_p.addParamValue('sourcefolder',folder,@(x)exist(x,'dir') == 7);
i_p.addParamValue('destfolder',folder,@(x)exist(x,'dir') == 7);

i_p.addParamValue('dthres',500,@(x)isnumeric(x) & x >= 0);
i_p.addParamValue('athres',800,@(x)isnumeric(x) & x >= 0);

i_p.addParamValue('nobkgd',true,@islogical);
i_p.addParamValue('nozero',false,@islogical);
i_p.addParamValue('ocimg',false,@islogical);

i_p.addParamValue('donor_prefix','Vi',@ischar);
i_p.addParamValue('accept_prefix','mTi',@ischar);

i_p.addParamValue('accept_chan','Venus',@ischar);
i_p.addParamValue('donor_chan','Teal',@ischar);
i_p.addParamValue('FRET_chan','FRET',@ischar);

i_p.addParamValue('status_messages',false,@(x)islogical(x));

i_p.parse(folder,varargin{:});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Main Program
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Preprocess images
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isempty(file_search('pre_\w+',folder))
    preprocess(fullfile('PreParams','PreParams_60x_default.mat'),folder)
end
prefix = 'pre_';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Bleedthrough Calculations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%The data in this section will be stored in a struct named data. This
%struct will have two levels, the first level is the type fluorophor
%present in the images, either donor or acceptor. The second level will be
%the settings of the microscope when the image was taken, these will be
%donor_chan, acceptor_chan and FRET_chan.

%Reading in files
files = struct();

files.donor = struct(...
    'donor_chan',[prefix i_p.Results.donor_prefix '\w+\d+\w+' i_p.Results.accept_chan '.TIF'],...
    'acceptor_chan',[prefix i_p.Results.donor_prefix '\w+\d+\w+' i_p.Results.donor_chan '.TIF'],...
    'FRET_chan',[prefix i_p.Results.donor_prefix '\w+\d+\w+' i_p.Results.FRET_chan '.TIF']);

files.acceptor = struct(...
    'donor_chan',[prefix i_p.Results.accept_prefix '\w+\d+\w+' i_p.Results.accept_chan '.TIF'],...
    'acceptor_chan',[prefix i_p.Results.accept_prefix '\w+\d+\w+' i_p.Results.donor_chan '.TIF'],...
    'FRET_chan',[prefix i_p.Results.accept_prefix '\w+\d+\w+' i_p.Results.FRET_chan '.TIF']);

data = struct();
for fluor = {'donor','acceptor'};
    fluor = fluor{1};  %#ok<FXSET>
    data.(fluor) = struct();
    for image_type = {'donor_chan','acceptor_chan','FRET_chan'}
        image_type = image_type{1}; %#ok<FXSET>
        data.(fluor).(image_type) = [];
        
        image_filenames = file_search(files.(fluor).(image_type),folder);
        for this_image_file = image_filenames
            temp = double(imread(fullfile(folder,this_image_file{1})));
            data.(fluor).(image_type) = [data.(fluor).(image_type);temp(:)];
        end
    end
end

% Filter out overexposed pixels or those below either the donor threshold, 
% for the donor images, or acceptor threshold for the acceptor images
overexposed_level = (2^i_p.Results.bitdepth) - 1;
passed_indexes = find(data.donor.donor_chan < overexposed_level & ...
    data.donor.donor_chan > i_p.Results.dthres & ...
    data.donor.acceptor_chan < overexposed_level & ...
    data.donor.FRET_chan < overexposed_level);

data.donor.donor_chan = data.donor.donor_chan(passed_indexes);
data.donor.acceptor_chan = data.donor.acceptor_chan(passed_indexes);
data.donor.FRET_chan = data.donor.FRET_chan(passed_indexes);

passed_indexes = find(data.acceptor.donor_chan < overexposed_level & ...
    data.acceptor.acceptor_chan > i_p.Results.athres & ...
    data.acceptor.acceptor_chan < overexposed_level & ...
    data.acceptor.FRET_chan < overexposed_level);

data.acceptor.donor_chan = data.acceptor.donor_chan(passed_indexes);
data.acceptor.acceptor_chan = data.acceptor.acceptor_chan(passed_indexes);
data.acceptor.FRET_chan = data.acceptor.FRET_chan(passed_indexes);

plot(data.acceptor.donor_chan,data.acceptor.FRET_chan./data.acceptor.donor_chan,'o');
mean(data.acceptor.FRET_chan./data.acceptor.donor_chan)
plot(data.donor.donor_chan,data.donor.FRET_chan./data.donor.donor_chan,'o');
mean(data.donor.FRET_chan./data.donor.donor_chan)

1;

toc;

% % [SaveParams.abt,SaveParams.dbt] = fret_bledth(,...
% %
% %
% %     [prefix i_p.Results.accept_prefix '\w+\d+\w+' i_p.Results.accept_chan '.TIF'],...
% %     [prefix i_p.Results.accept_prefix '\w+\d+\w+' i_p.Results.donor_chan '.TIF'],...
% %     [prefix i_p.Results.accept_prefix '\w+\d+\w+' i_p.Results.FRET_chan '.TIF'],...
% %     i_p.Results);
% save(fullfile(pwd,folder,['SaveParams_' folder '.mat']),'-struct','SaveParams');
