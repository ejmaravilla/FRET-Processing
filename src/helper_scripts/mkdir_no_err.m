function mkdir_with_create(dir)

if not(exist(dir,'dir'))
    mkdir(dir);
end