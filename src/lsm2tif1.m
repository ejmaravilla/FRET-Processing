function lsm2tif1( regexpress,source,varargin )
%lsm2tif This funnction receives an lsm stack and converts it to a set of tifs

%   Sample Calls:
%   lsm2tif('wt_\d+.lsm,pwd,[],'tl') - no specification of channels, yes timelapse
%   lsm2tif('BG_\d+.lsm,'Blob') - no specification of channels, folder specification
%   lsm2tif('vints_\d+.lsm,pwd,{'Teal','TVFRET','Venus'}) - provided channel names
%
%   Inputs:
%   regexpress - a regular expression representing the base name of the
%   files to convert
%   source - the folder in which the files reside (must be on path)
%   varargin:
%       varargin{1} - names for the different channels, if not provided,
%       will call ch1, ch2, etc
%       varargin{2} - anything put in this position will tell the function
%       that it is a timelapse and thus has multiple channels and
%       timepoints
%
%   Outputs:
%   No express outputs, but the function writes out .tif files
%   corresponding to each channel and time point of the lsm stack
%
%   

files = file_search(regexpress,source);
files = fullfile(source,files);
n = nargin;

% Loop over number of files
for i = 1 : length(files)
    var = tiffread29(files{i});
    if nargin ~= 4
        % Delete name after last dot
        dots = strfind(var.filename,'.');
        var.filename(dots(end):end)=[];
        % Loop over length of data field        
        for j = 1 : length(var.data)
            if n == 2
                shortn = [var.filename '_w' num2str(j) '.TIF']; 
            else  
                shortn = [var.filename '_w' num2str(j) varargin{1}{j} '.TIF'];
            end
            imwrite(var.data{j},shortn,'tif')
        end
    else
        tp = length(var);
        dots = strfind(var(1).filename,'.');
        var(1).filename(dots(end):end)=[];
        ch = length(var(1).data);
        
        for j = 1:tp
            for k = 1:ch
                if isempty(varargin{1})
                    shortn = [var(1).filename '_w' num2str(k) '_t' num2str(j) '.TIF'];
                else
                    shortn = [var(1).filename '_w' num2str(k) varargin{1}{k} '_t' num2str(j) '.TIF'];
                end
                imwrite(var(j).data{k},shortn,'tif')
            end
        end
    end
    
    
end
end

