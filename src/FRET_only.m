% This script applies FRET corrections and, if desired, calculates FRET
% efficiency and donor-to-acceptor ratio.

rehash
imin = [venus_thres 0 -10000];

if ~exist(fullfile(folder,'FRET Correct Images'),'dir')
    mkdir(folder,'FRET Correct Images')
    if strcmp(FRETeff,'y')
        fret_correct([prefix exp_name '\w+\d+\w+' Achannel '.TIF'],...
            [prefix exp_name '\w+\d+\w+' Dchannel '.TIF'],...
            [prefix exp_name '\w+\d+\w+' FRETchannel '.TIF'],...
            abt,dbt,imin,FRETeff,leave_neg,folder,G,k);
    else
        fret_correct([prefix exp_name '\w+\d+\w+' Achannel '.TIF'],...
            [prefix exp_name '\w+\d+\w+' Dchannel '.TIF'],...
            [prefix exp_name '\w+\d+\w+' FRETchannel '.TIF'],...
            abt,dbt,imin,FRETeff,leave_neg,folder);
    end
end
addpath(fullfile(folder,'FRET Correct Images'))