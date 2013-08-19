function blob_selector( bfn,cols,minv,maxv,folder )

bfl = file_search(bfn,folder);

nf = length(bfl);

ncol = length(cols);

for i = 1 : nf 
    
    binfo = load(bfl{i});
    
    tmask = zeros(size(binfo));
    
    for j = 1 : ncol
        
        w = find(binfo(:,cols(j)) > minv(j) & binfo(:,cols(j)) < maxv(j));
        
        tmask(w,cols(j))= 1;
        
    end
    
    tmask = sum(tmask,2);
    
    w = find(tmask == ncol);
    
    nbinfo = binfo(w,:);
    
        
    save(['s',bfl{i}],'nbinfo','-ascii')   


end

end