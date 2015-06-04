function app_cols_blb(blb_file,newcols,folder,num_channel)

% Adds columns to blob file

img_col = 4*(num_channel+1)+7;

d = load(blb_file);
[~,w] = size(d);
[~,n] = size(newcols);
if w == img_col
    if n == 1
        d(:,end+1) = newcols;
        disp('Boundaries: None --> Open');
    elseif n == 2
        d(:,end+1:end+2) = newcols;
        disp('Boundaries: None --> Closed');
    elseif n == 12
        d(:,end+1:end+12) = newcols;
        disp('Boundaries: None --> Closed + RegionParams');
    end
elseif w == img_col+1
    if n == 1
        d(:,end) = newcols;
        disp('Boundaries: Open --> Open');
    elseif n == 2
        d(:,end:end+1) = newcols;
        disp('Boundaries: Open --> Closed');
    elseif n == 12
        d(:,end:end+11) = newcols;
        disp('Boundaries: Open --> Closed + RegionParams');
    end
elseif w == img_col+2
    if n == 1
        d(:,end-1) = newcols;
        d(:,end) = [];
        disp('Boundaries: Closed --> Open');
    end
    if n == 2
        d(:,end-1:end) = newcols;
        disp('Boundaries: Closed --> Closed');
    end
    if n == 12
        d(:,end-1:end+10) = newcols;
        disp('Boundaries: Closed --> Closed + RegionParams');
    end
elseif w == img_col+12
    if n == 1
        d(:,end-11) = newcols;
        d(:,end-10:end) = [];
        disp('Boundaries: Closed + RegionParams --> Open');
    end
    if n == 2
        d(:,end-11:end-10) = newcols;
        d(:,end-10:end) = [];
        disp('Boundaries: Closed + RegionParams --> Closed');
    end
    if n == 12
        d(:,end-11:end) = newcols;
        disp('Boundaries: Closed + RegionParams --> Closed + RegionParams');
    end
end
save(fullfile(pwd,folder,blb_file),'d','-ascii')
end

