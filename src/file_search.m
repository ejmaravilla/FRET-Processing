function filecell = file_search(exp,folder)

% a function to find files of a given expression in a particular folder

listing = dir(folder);
listing(1:2)=[];
isfolder = {listing.isdir};
files = {listing.name};
for m = 1:length(isfolder)
    if isfolder{m} == 1
        sublist = dir(fullfile(folder,listing(m).name));
        sublist(1:2) = [];
        subfiles = {sublist.name};
        files = [files subfiles];
    end
end

match = regexp(files,exp);
indi = [];
for i = 1:length(match)
    if match{i}==1
        indi = [indi i];
    end
end
filecell = files(indi);