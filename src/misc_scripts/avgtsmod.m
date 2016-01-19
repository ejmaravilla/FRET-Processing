folder = 'E:\Aarti\MDCK junctional FRET\TSMod 250_1000_300\FRET Correct Images';
addpath(folder)
eff_files = file_search('eff_pre_Tsmod_\d+_w2TVFRET.TIF',folder);
means = zeros(1,length(eff_files));
for i = 1:length(eff_files)
    a = imread(eff_files{i});
    means(i) = mean(a(a>0));
end
totmean = mean(means);
stdev = std(means);