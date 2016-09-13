folder = 'E:\Aarti\MDCK junctional FRET\TSMod 250_1000_300\FRET Correct Images';
addpath(folder)
eff_files = file_search('eff_pre_Tsmod_\d+_w2TVFRET.TIF',folder);
dpa_files = file_search('dpa_pre_Tsmod_\d+_w2TVFRET.TIF',folder);
bsa_files = file_search('bsa_pre_Tsmod_\d+_w1Venus.TIF',folder);
means = zeros(1,length(eff_files));
a = imread(eff_files{1});
[r,c] = size(a);
masked = zeros(r,c,length(eff_files));
for i = 1:length(eff_files)
    a = imread(eff_files{i});
    b = imread(dpa_files{i});
    c = imread(bsa_files{i});
    logic = a>0 & b<5 & c>500;
    masked(:,:,i) = a.*logic;
    means(i) = mean(a(a>0 & b<3 & c > 500));
end
totmean = mean(means);
stdev = std(means);