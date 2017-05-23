% This script figures out what channel to draw cell boundaries on, and
% whether boundaries are manual or automatic, calling the appropriate
% function to create the cell masks.

rehash

if ~exist('Achannel','var')
    Achannel = '';
end

if strcmpi(BoundaryChannel,Achannel)
    files = ['bsa_' prefix exp_name '\w+' Achannel '.TIF'];
elseif strcmpi(BoundaryChannel,FRETchannel)
    files = [prefix exp_name '\w+' FRETchannel '.TIF'];
elseif strcmpi(BoundaryChannel,Schannel)
    files = [prefix exp_name '\w+' Schannel '.TIF'];
end

if isempty(file_search('polymask_\w+',folder))
    mkdir(fullfile(folder,'Cell Mask Images'))
    if strcmpi(manual_or_auto,'manual')
        cell_outline_manual(files,folder);
    elseif strcmpi(manual_or_auto,'auto')
        cell_thresh = cell_outline_auto(files,1000,folder);
    elseif strcmpi(manual_or_auto,'semiauto')
        cell_outline_semiauto(files,75,folder);
    elseif strcmpi(manual_or_auto,'semiauto1')
        cell_outline_semiauto1(files,0,folder);
    elseif strcmpi(manual_or_auto,'polymanual')
        cell_outline_polymanual(files,folder);
    end
end

addpath(fullfile(folder,'Cell Mask Images'))