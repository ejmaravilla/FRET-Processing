function fret_correct(aexp,dexp,fexp,abtfn,dbtfn,varargin)
% outputs = fret_correct(af,df,fr,abtfn,dbtfn,params)
% outputs = fret_correct(af,df,fr,abtfn,dbtfn,baf,bdf,bfr,params)

% PURPOSE: A program to remove the intensity in a set of FRET images due to
% bleed-throughs or cross-talks. Can do linear or non-linear bleedthroughs
% and cross-talks. Linear bleed-throughs assume that these percentages are
% constant as a function of brightness. Non-linear bleed-throughs do not.
% If all four corrections are used, the corrections scheme becomes a
% non-linear set of coupled equations. In this case, Newton's method is
% used to solve the set of equations. This is not fully validated and
% probably should have some sort of regularization to help enure that the
% solution is a global minimum and not a local one

% Non-linear corrections are done by linearly interpolating the correction
% curves.

% Background subtraction is handled one of two ways. If background levels
% are included, then these images are averaged and subtracted from the
% single and double labeled images. These are called bsff images. If
% background images are not included, then the background (most likely
% pixel in the picture) is subtracted from the image. This will not account
% for variations in illumination. These images are named bs.

%--------------------------------------------------------------------------

% Created 9/5/12 by Katheryn Rothenberg
% Updated 9/14/12 by Wes Maloney - Translated original body of all_cor,
%       all_cor_func, deunder, norm_fret, align_images subfunctions
% Updated 9/25/12 by Katheryn Rothenberg - Translated original body of main
%       function. Debugged and running except for final .tif writing.
% Updated 11/27/12 by Katheryn Rothenberg - Edited the method of saving
%       .tif images from imwrite to using the Tiff class and fixed the
%       check for linear or nonlinear correction
% Updated 11/29/12 by Katheryn Rothenberg - Removed the spline_intrp
%       subfunction and replaced with a call to the cubic spline function.
%       This resulted in final images with very little variation from the
%       test images while using the test bleed through files. Also, added
%       the sourcefolder and dest folder fields to the params structure.

%--------------------------------------------------------------------------

% INPUTS:

% inputs that are required to run the function are as follows:
% af - base name for the acceptor channel images of a double labeled sample
% df - base name for the donor channel images of a double labeled sample
% fr - base name to find the FRET channel images of a double labeled sample
% abtfn - specifies acceptor bleed-through into the FRET channel, either
% number or file
% dbtfn - specifies donor bleed-through into the FRET channel, either
% number or file

% inputs that are optional are as follows:
% baf - base name for the acceptor channel images of the background
% bdf - base name for the donor channel images of the background
% bfr - base name for the FRET channel images of the background

% params will be a structure containing a field for each of the following
% parameters:
% sourcefolder - specifies the folder containing all the images being
% analyzed
% destfolder - specifies the destination folder for the output files and
% images
% range - sets the pixels that images will be moved on, use if you think images
% are not aligned, shifts images over this range and looks for max
% correlation
% ocimg - if set, the program will write out the images
% bit - specifies the bit of the image
% imin - the minimum intensity to allow into the output images, if either
% acceptor or donor image is below this intensity, it will be zeroed in
% output images
% outname - manually specifies output name
% double_norm - normalize to the intensity of the corrected acceptor and
% donor images
% donor_norm - normalize to the intensity of the corrected donor images
% actfn - specifies the acceptor cross-talk into the donor channel, can
% either be a number or file, drastically increases runtime
% dctfn - specifies the donor cross-talk into the acceptor channel, can
% either be a number or file, drastically increases runtime
% corrmax - useful when running non-linear corrections with all four terms.
% The cross-talks often decrease to zero at large brightnesses. Cross-talk
% correction will not be performed above this threshold, has no use in
% linear or non-linear correction of two bleed-through terms

%--------------------------------------------------------------------------

% OUTPUTS:

% If ocimg is set, program writes out background subtracted version of the
% data images as well as a corrected FRET, and a normalized FRET image.
% Corrected FRET images are labeled c. and the normalized images are
% normalized to the acceptor and entitled cna.

%--------------------------------------------------------------------------

param = varargin{end};
if ~isfield(param,'bit')
    param.bit = 12;
end
if ~isfield(param,'actfn')
    param.actfn = 0;
end
if ~isfield(param,'dctfn')
    param.dctfn = 0;
end
if ~isfield(param,'corrmax')
    param.corrmax = 1e6;
end

param.bin = 1.0;
nps = nargin-1;
if nps ~= 8
    bkimg = 0;
else
    bkimg = 1;
end

af = file_search(aexp,param.sourcefolder);
df = file_search(dexp,param.sourcefolder);
fr = file_search(fexp,param.sourcefolder);

% Check images found
if isempty(af)
    disp('WARNING, No Acceptor Images')
end
if isempty(df)
    disp('WARNING, No Donor Images')
end
if isempty(fr)
    disp('WARNING, No FRET Images')
end

% Check number of images
if length(af)~=length(df)
    disp('WARNING, Number of Donor and Acceptor Images Not the Same')
end
if length(af)~=length(fr)
    disp('WARNING, Number of FRET and Acceptor Images Not the Same')
end
if length(df)~=length(fr)
    disp('WARNING, Number of Donor and FRET Images Not the Same')
end

% Determine if linear or non-linear corrections
lin = 0;
nonl = 0;
if ischar(abtfn{1}) == 1
    nonl = 1;
else
    lin = 1;
end

if lin
    abt = double(abtfn{1});
    dbt = double(dbtfn{1});
    act = double(param.actfn);
    dct = double(param.dctfn);
end

if nonl
    % Get bleed-through names
    ndbt = length(dbtfn);
    nabt = length(abtfn);
    if ndbt == 0
        disp('No non-linear donor bleed through file found')
    end
    if nabt == 0
        disp('No non-linear acceptor bleed through file found')
    end
    for i = 1:ndbt
        sdbt{i} = load([dbtfn{i} '.dat']);  %#ok<AGROW>
        sabt{i} = load([abtfn{i} '.dat']); %#ok<AGROW>
    end
    if param.dctfn
        for i = 1:length(param.dctfn)
            sdct{i} = load([param.dctfn{i} '.dat']); %#ok<NASGU>
        end
        ndct = length(param.dctfn);
        dctf = 1;
    else
        ndct = 1;
        dctf = 0;
    end
    if param.actfn
        for i = 1:length(param.actfn)
            sact{i} = load([param.actfn{i} '.dat']);
        end
        nact = length(param.actfn);
        actf = 1;
    else
        nact = 1;
        actf = 0;
    end
    if actf+dctf == 2
        ctf = 1;
    else
        ctf = 0;
    end
    if actf+dctf == 1
        fprintf('Please use none or both cross-talk corrections\n')
    end
end

if bkimg
    baf = file_search(varargin{1},param.sourcefolder);
    nba = length(baf);
    bdf = file_search(varargin{2},param.sourcefolder);
    nbd = length(bdf);
    bfr = file_search(varargin{3},param.soucefolder);
    nbf = length(bfr);
    
    % Check background images found
    if nba == 0
        disp('WARNING, No Background Acceptor Images')
    end
    if nbf == 0
        disp('WARNING, No Background FRET Images')
    end
    if nbd == 0
        disp('WARNING, No Background Donor Images')
    end
    
    % Check number of background images
    if nba ~= nbd
        disp('WARNING, Number of Background Donor and Acceptor Images Not the Same')
    end
    if nba ~= nbf
        disp('WARNING, Number of Background FRET and Acceptor Images Not the Same')
    end
    if nbd ~= nbf
        disp('WARNING, Number of Background Donor and FRET Images Not the Same')
    end
    
    tot = 0;
    for i = 1:nba
        tot = tot + double(imread(baf{i}));
    end
    axamb = tot./nba;
    if isfield(param,'outname')
        imwrite2tif(axamb,[],fullfile(pwd,param.destfolder,['axamb_' param.outname]),'single')
    else
        imwrite2tif(axamb,[],fullfile(pwd,param.destfolder,'axamb'),'single')
    end
    
    tot2 = 0;
    for i = 1:nbd
        tot2 = tot2+double(imread(bdf{i}));
    end
    dxdmb = tot2./nbd;
    if isfield(param,'outname')
        imwrite2tif(dxdmb,[],fullfile(pwd,param.destfolder,['dxdmb_' param.outname]),'single')
    else
        imwrite2tif(dxdmb,[],fullfile(pwd,param.destfolder,'dxdmb'),'single')
    end
    
    tot3 = 0;
    for i = 1:nbf
        tot3 = tot3+double(imread(bfr{i}));
    end
    dxamb = tot3./nbf;
    if isfield(param,'outname')
        imwrite2tif(dxamb,[],fullfile(pwd,param.destfolder,['dxamb_' param.outname]),'single')
    else
        imwrite2tif(dxamb,[],fullfile(pwd,param.destfolder,'dxamb'),'single')
    end
end

for i = 1:length(df)
    % Get fluorescent images
    axam = double(imread(fullfile(param.sourcefolder,af{i})));
    dxdm = double(imread(fullfile(param.sourcefolder,df{i})));
    dxam = double(imread(fullfile(param.sourcefolder,fr{i})));
    
    % Optionally align images
    if isfield(param,'range')
        ds = align_images(dxdm,dxam,param.range);
        as = align_images(axam,dxam,param.range);
        fprintf('%.2f\n',ds)
        fprintf('%.2f\n',as)
        if max(abs(ds)) == param.range || max(abs(as)) == param.range
            fprintf('%.2f\n',af{i})
            fprintf('%.2f\n',df{i})
            fprintf('%.2f\n',fr{i})
            fprintf('range maximum reached, re-run with larger range\n')
        end
        dxdm = circshift(dxdm,[dx(1) ds(2)]);
        axam = circshift(axam,[as(1) as(2)]);
    end
    [axam, dxdm, dxam] = deover(axam,dxdm,dxam,param.bit);
    
    % Do flatfielding and background subtraction
    if bkimg
        dxdm = bs_ff(dxdm,dxdmb,param);
        dxam = bs_ff(dxam,dxamb,param);
        axam = bs_ff(axam,axamb,param);
    else
        dxdm = bs_ff(dxdm,param);
        dxam = bs_ff(dxam,param);
        axam = bs_ff(axam,param);
    end
    
    if isfield(param,'imin')
        [axam, dxdm, dxam] = deunder(axam,dxdm,dxam,param.imin);
    end
    
    if lin
        % Following supplemental material of Chen, Puhl et al BJ Lett 2006
        iaa = (dbt.*axam-dct.*dxam)./(dbt-dct.*abt);
        idd = (abt.*dxdm-act.*dxam)./(abt-act.*dbt);
        fc = dxam-abt.*iaa-dbt.*idd;
        if ~isfield(param,'leave_neg')
            iaa(iaa<0) = 0;
            idd(idd<0) = 0;
            fc(fc<0) = 0;
        end
    end
    
    if nonl
        if ~isfield(param,'imin')
            param.imin = [0 0 -1000];
        end
        % Use an image to size the array
        abt = axam;
        % Zero the correction factors
        abt(:,:)=0;
        dbt = abt;
        act = abt;
        dct = abt;
        w = find(axam >= param.imin(1) & dxdm >= param.imin(2) & dxam >= param.imin(3));
        ai = axam(w);
        di = dxdm(w);
        fi = dxam(w);
        
        if all(sabt{1}~=0)
            abt(w) = spline_intrp(sabt{1},ai);
        end
        if all(sdbt{1}~=0)
            dbt(w) = spline_intrp(sdbt{1},di);
        end
        
        % Make corrections
        iaa = axam;
        idd = dxdm;
        
        fc = dxam-abt.*iaa-dbt.*idd;
        if ~isfield(param,'leave_neg')
            fc(fc < 0) = 0;
        end

    end
    
    nafc = norm_fret(fc,iaa);
    if isfield(param,'outname')
        nfrn = ['_' param.outname fr{i}];
        ndfn = ['_' param.outname df{i}];
        nafn = ['_' param.outname af{i}];
    else
        nfrn = ['_' fr{i}];
        ndfn = ['_' df{i}];
        nafn = ['_' af{i}];
    end
    
    target_folder = fileparts([pwd '/' param.destfolder '/c' nfrn]);
    if (not(exist(target_folder,'dir')))
        mkdir(target_folder);
    end
    imwrite2tif(fc,[],fullfile(pwd,param.destfolder,['c' nfrn]),'single')
    
    target_folder = fileparts([pwd '/' param.destfolder '/cna' nfrn]);
    if (not(exist(target_folder,'dir')))
        mkdir(target_folder);
    end
    imwrite2tif(nafc,[],fullfile(pwd,param.destfolder,['cna' nfrn]),'single')

    if param.donor_norm
        ndfc = norm_fret(fc,idd);
        imwrite2tif(ndfc,fullfile(pwd,param.destfolder,['cnd' nfrn]),'single')
    end
    if param.double_norm
        nandfc = norm_fret(fc,iaa,idd);
        imwrite2tif(nandfc,fullfile(pwd,param.destfolder,['cnand' nfrn]),'single')
    end
    
    if param.ocimg
        if bkimg
            imwrite2tif(idd,[],fullfile(pwd,param.destfolder,['bsffd' ndfn]),'single')
            imwrite2tif(iaa,[],fullfile(pwd,param.destfolder,['bsffa' nafn]),'single')
        else
            target_folder = fileparts([pwd '/' param.destfolder '/bsd' ndfn]);
            if (not(exist(target_folder,'dir')))
                mkdir(target_folder);
            end
            imwrite2tif(idd,[],fullfile(pwd,param.destfolder,['bsd' ndfn]),'single')
            
            target_folder = fileparts([pwd '/' param.destfolder '/bsa' nafn]);
            if (not(exist(target_folder,'dir')))
                mkdir(target_folder);
            end
            imwrite2tif(iaa,[],fullfile(pwd,param.destfolder,['bsa' nafn]),'single')
        end
    end
    
end

end

%--------------------------------------------------------------------------
% SUBFUNCTIONS:

function pos = align_images(img,fi,range)

% Create the vector of indices to search over
v = zeros(1,2*range+1);
p=0:range;
v(1:range+1)=p;
v(range+2:end)=-p(2:end);
v=sort(v);
nele=length(v);
%Define some storage variables and comparison vectors.
cstr=0;
nele2 = length(fi);
temp2 = reshape(fi,1,nele2);

%Move flourescent images over FRET image, serchesfor global maximum over
%limited range.
%If optimum position is equal to +/- of range value re-run with larger
%range value.
for i=1:nele
    for j=1:nele
        temp=reshape(circshift(img,[v(i) v(j)]),1,nele2);
        [r,p]=corrcoef(temp,temp2);
        c=r(1,2);
        if c >= cstr
            cstr=c;
            pos=[v(i),v(j)];
        end
    end
end

end

function ftemp = norm_fret(f,n,varargin)

n_params = nargin;
if n_params== 2
    ftemp=f;
    ntemp=n;
    wnz=find(n ~= 0);
    wz =find(n == 0);
    if ~isempty(wnz)
        ftemp(wnz)=ftemp(wnz)./ntemp(wnz);
    end
    if ~isempty(wz)
        ftemp(wz)=0;
    end
elseif n_params == 3
    ftemp=f;
    ntemp=n;
    ntemp2=n2;
    wnz=find(n ~= 0 & n2 ~= 0);
    ftemp(wnz)=ftemp(wnz)./(ntemp(wnz).*ntemp2(wnz));
    ftemp(n == 0)=0;
    ftemp(n2 == 0)=0;
end
end

function [a,b,c] = deunder(a,b,c,thres)
% Identify pixels less than a certain value. If any of the pixels in a
% single image is less than the threshold, the pixel will be set to zero in
% all images

w=find(a < thres(1) | b < thres(2) | c < thres(3));
if ~isempty(w)
    a(w)=0;
    b(w)=0;
    c(w)=0;
end
end

function res = spline_intrp(cor,img)
% Calculate 2nd derivative by hand b/c more stable than spl_int. Also
% spl_interp requires X variables be in ascending order

x = sort(cor(:,1));
[x,u] = unique(x);
y = cor(:,2);
y = y(u);

if max(img) > max(x)
    x = [x; max(img)];
    y = [y; y(end)];
end

d = deriv_k(x,y);
d2 = deriv_k(x,d);
res = spl_interp_k(x,y,d2,img);

end

