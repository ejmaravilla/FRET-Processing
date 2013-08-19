function setup_experiment(exp_data_dir,varargin)

tic;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Setup variables and parse command line
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_p = inputParser;

i_p.addRequired('exp_data_dir',@(x)exist(x,'dir')==7);
i_p.addOptional('results_dir',@(x)exist(x,'dir')==7);
i_p.addParamValue('debug',0,@islogical);

i_p.parse(exp_data_dir,varargin{:});

addpath('helper_scripts');

%results_dir isn't specified in the options, assuming the same data
%structure is required for the results directory
if(any(strcmp(i_p.UsingDefaults,'results_dir')))
    results_dir = regexprep(exp_data_dir,'/data/','/results/');
else
    results_dir = i_p.Results.results_dir;
end

mkdir_no_err(results_dir);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Main Program
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

exp_data_files = dir(exp_data_dir);
exp_data_files = exp_data_files(3:end);
exp_data_files = {exp_data_files.name};

file_organization = cell(0);
file_organization{end+1} = struct('search_str','Teal','target_filename','donor.png');
file_organization{end+1} = struct('search_str','Venus','target_filename','acceptor.png');
file_organization{end+1} = struct('search_str','FRET','target_filename','FRET.png');
file_organization{end+1} = struct('search_str','Cy5','target_filename','FA.png');

parfor i=1:length(file_organization)
    file_matches = regexp(exp_data_files,file_organization{i}.search_str,'match');
    
    i_num = 1;
    for j = 1:length(file_matches)
        if not(isempty(file_matches{j}))
            output_folder = fullfile(results_dir,sprintf('%04d',i_num));
            mkdir_no_err(output_folder);
            
            temp = imread(fullfile(exp_data_dir,exp_data_files{j}));
            
            output_file = fullfile(output_folder,file_organization{i}.target_filename);
            
            imwrite(uint16(temp),output_file,'bitdepth',16);
            
            temp2 = imread(output_file);
            
            assert(all(all(temp == temp2)));
            i_num = i_num + 1;
        end
    end
end

toc;
end