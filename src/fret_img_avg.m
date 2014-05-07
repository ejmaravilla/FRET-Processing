function fret_img_avg(b,thresh,folder)

fl = file_search([b '\w+'],folder);
nele = length(fl);
res = zeros(nele,5);

t1 = 'w1Venus.TIF';
t2 = 'w2TVFRET.TIF';
t3 = 'w3Teal.TIF';

for i = 1:nele
    f = fl{i};
    stop = strfind(f,'_');
    f2 = f(1:stop(end));
    base = f2(5:end);

    a = imread(['bsa_' base t1]);
    d = imread(['bsd_' base t3]);
    nc = imread(['cna_' base t2]);
    c = imread(['c_' base t2]);
    
    w = find(a > thresh(1) & d > thresh(2) & c > thresh(3));
    nw = length(w);
    
    ma = mean(a(w));
    mc = mean(c(w));
    md = mean(d(w));
    mnc = mean(nc(w));
    
    res(i,1) = mnc;
    res(i,2) = ma;
    res(i,3) = mc;
    res(i,4) = md;
    res(i,5) = nw;
    
end

fid = fopen(fullfile(folder,['wc_avg_' b '_' num2str(thresh(1)) '_' num2str(thresh(2)) '_' num2str(thresh(3)) '.txt']),'w');
for i = 1:nele
    fprintf(fid,'%s\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\n',fl{i},res(i,:));
end

fclose(fid);

end