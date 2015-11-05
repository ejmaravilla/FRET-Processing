main_folder = input('Enter the main folder containing data folders: ','s');
info = dir(main_folder);
info(1:2) = [];
folders = {info.name};
for i = 1:length(folders)
    test_folder = fullfile(main_folder,folders{i});
    MAIN_PIPELINE(test_folder)
end