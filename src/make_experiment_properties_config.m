function SaveParams = make_experiment_properties_config

SaveParams.folder = '../results/9-24-2014 EZR Cell Line Tests/';

% General Experiment Properties
% Enter the names at the beginning of each type of experiment you want to
% assess
SaveParams.exp_cell = cell(1);
SaveParams.exp_cell{end} = 'A431-TS';
SaveParams.exp_cell{end+1} = 'A431-TL';
SaveParams.exp_cell{end+1} = 'caco-TS';
SaveParams.exp_cell{end+1} = 'caco-TL';

SaveParams.num_exp = length(SaveParams.exp_cell);
    
SaveParams.num_channel = 3;

%These parameters will be used to find the file that is the acceptor
%channel, donor and FRET channels. They should be unique strings that match
%only the corresponding channel
SaveParams.Achannel = 'Venus';
SaveParams.FRETchannel = 'TVFRET';
SaveParams.Dchannel = 'Teal';

%Bleedthrough Parameters:
% -dthres: threshold for the donor signal for consideration in bleedthrough
% -athres: threshold for the acceptor signal for consideration in bleedthrough
% -abt: "a"cceptor "b"leed"t"hrough into the FRET channel
% -dbt: "d"onor "b"leed"t"hrough into the FRET channel
SaveParams.bt = 'n';
SaveParams.dthres = 500;
SaveParams.athres = 800;

%These settings work for Teal-Venus FRET with 1000 (donor), 1000
%(acceptor), 1500 (FRET) exposure times
% SaveParams.abt = 0.26;
% SaveParams.dbt = 0.96;
    
%These settings work for Teal-Venus FRET with 500 (donor), 500 (acceptor),
%500 (FRET) exposure times 
SaveParams.abt = 0.18;
SaveParams.dbt = 0.90;


%FRET Correction Settings
% -correct: should we do FRET correction ('y' or 'n')
SaveParams.correct = 'y';

if strcmpi(SaveParams.correct,'y')
    SaveParams.venus_thres = 100;
end

save(fullfile(SaveParams.folder,'SaveParams.mat'),'-struct','SaveParams');