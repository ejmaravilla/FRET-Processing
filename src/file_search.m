function file_matches = file_search(exp,folder)
listing = dir(folder);
listing(1:2) = [];
files = {listing.name};

% match all regular expressions
% indi = cellfun(@(x)(~isempty(x)),regexp(files,exp));
match = regexp(files,exp);
file_matches = cell(0);
for i = 1:length(match)
    if match{i}==1
        file_matches{end+1} = fullfile(folder,files{i}); %#ok<AGROW>
    end
end