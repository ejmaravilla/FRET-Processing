function app_cols_blb(blb_file,newcols,folder,num_channel)

% Adds columns to blob file

img_col = 2*num_channel+7;
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
    elseif n == 9
        d(:,end+1:end+9) = newcols;
        disp('Boundaries: None --> Closed + RegionParams');
    end
elseif w == img_col+1
    if n == 1
        d(:,end) = newcols;
        disp('Boundaries: Open --> Open');
    elseif n == 2
        d(:,end:end+1) = newcols;
        disp('Boundaries: Open --> Closed');
    elseif n == 9
        d(:,end:end+8) = newcols;
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
    if n == 9
        d(:,end-1:end+7) = newcols;
        disp('Boundaries: Closed --> Closed + RegionParams');
    end
elseif w == img_col+9
    if n == 1
        d(:,end-8) = newcols;
        d(:,end-7:end) = [];
        disp('Boundaries: Closed + RegionParams --> Open');
    end
    if n == 2
        d(:,end-8:end-7) = newcols;
        d(:,end-7:end) = [];
        disp('Boundaries: Closed + RegionParams --> Closed');
    end
    if n == 9
        d(:,end-8:end) = newcols;
        disp('Boundaries: Closed + RegionParams --> Closed + RegionParams');
    end
end
save(fullfile(pwd,folder,blb_file),'d','-ascii')
end

