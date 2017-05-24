function fret_correct(aexp,dexp,fexp,abt,dbt,imin,FRETeff,leave_neg,folder,varargin)
% fret_correct(af,df,fr,abt,dbt,imin,FRETeff,leave_neg,folder) - if FRETeff is 'n'
% fret_correct(af,df,fr,abt,dbt,imin,FRETeff,leave_neg,folder,G,k) - if FRET eff is 'y'

% PURPOSE: A program to remove the intensity in a set of FRET images due to
% bleed-throughs or cross-talks. Currently accounts for only linear bleed-throughs.
% Linear bleed-throughs assume that these percentages are
% constant as a function of brightness.

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
% Updated 06/17/14 by Katheryn Rothenberg - cut out all non-linear
%       calculations and considerations of cross-talk and dealing with
%       background images.
% Updated 01/20/14 by Andrew LaCroix - added G and k inputs following Chen
%       Puhl BJ 2006 calculations for FRET efficiency and Donor molecules/
%       Acceptor molecules. Also modified param.leave_neg call in function
%       and file writing
% Updated 09/30/15 by Katheryn Rothenberg - adjusted inputs and how output
%       images are saved.

%--------------------------------------------------------------------------

% INPUTS:

% inputs that are required to run the function are as follows:
% af - base name for the acceptor channel images of a double labeled sample
% df - base name for the donor channel images of a double labeled sample
% fr - base name to find the FRET channel images of a double labeled sample
% abt - specifies acceptor bleed-through into the FRET channel
% dbt - specifies donor bleed-through into the FRET channel
% imin - the minimum intensity to allow into the output images, if either
%   acceptor or donor image is below this intensity, it will be zeroed in
%   output images
% FRETeff - tells whether FRET efficiency and donor-to-acceptor ratio should be calculated.
% leave_neg - indicates whether to leave negative values in the images or
%   to take them out
% folder - specifies the folder containing all the images being analyzed

% inputs that are required only if FRETeff is 'y':
% G = G factor from Chen BJ 2006
% k = k factor from Chen BJ 2006

%--------------------------------------------------------------------------

% OUTPUTS:

% Corrected FRET images are labeled c_ and the normalized images are
% normalized to the acceptor and entitled cna_ FRET efficiency values are
% labeled eff_ and donor molecule per acceptor molecule images are labeled
% dpa_ (Donor Per Acceptor)

%--------------------------------------------------------------------------
if (length(varargin) == 2)
    G = varargin{1};
    k = varargin{2};
end

bit = 16;

af = file_search(aexp,folder);
df = file_search(dexp,folder);
fr = file_search(fexp,folder);

% Check images found
if isempty(af)
    warning(['No Acceptor Images found, searched using: ',aexp])
end
if isempty(df)
    warning(['No Donor Images, searched using: ',dexp])
end
if isempty(fr)
    warning(['No FRET Images, searched using: ', fexp])
end

% Check number of images
if length(af)~=length(df)
    warning('Number of Donor and Acceptor Images Not the Same')
end
if length(af)~=length(fr)
    warning('Number of FRET and Acceptor Images Not the Same')
end
if length(df)~=length(fr)
    warning('Number of Donor and FRET Images Not the Same')
end

imin_toggle = exist('imin','var');
parfor i = 1:length(df)
    % Get fluorescent images
    axam = double(imread(af{i}));
    dxdm = double(imread(df{i}));
    dxam = double(imread(fr{i}));
    
    [axam, dxdm, dxam] = deover(axam,dxdm,dxam,bit);
    
    if imin_toggle
        [axam, dxdm, dxam] = deunder(axam,dxdm,dxam,imin);
    end
    
    % Following supplemental material of Chen, Puhl et al BJ Lett 2006
    iaa = axam;
    idd = dxdm;
    fc = dxam-abt.*iaa-dbt.*idd;
    
    if strcmpi(FRETeff,'y')
        eff = (fc./G)./(idd+(fc./G));
        dpa = (idd+(fc./G))./(iaa.*k);
    end
    
    if leave_neg == 0
        iaa(iaa<0) = 0;
        idd(idd<0) = 0;
        fc(fc<0) = 0;
        if strcmpi(FRETeff,'y')
            eff(eff<0) = 0;
            dpa(dpa<0) = 0;
        end
    end
    
    % Get rid of NaN
    iaa(isnan(iaa)) = 0;
    idd(isnan(idd)) = 0;
    fc(isnan(fc)) = 0;
    if strcmpi(FRETeff,'y')
        eff(isnan(eff)) = 0;
        dpa(isnan(dpa)) = 0;
    end
    
    nafc = norm_fret(fc,iaa);
    
    % Name output images
    iaa_name = fullfile(folder,'FRET Correct Images',['bsa_' af{i}]);
    idd_name = fullfile(folder,'FRET Correct Images',['bsd_' df{i}]);
    fc_name = fullfile(folder,'FRET Correct Images',['c_' fr{i}]);
    nafc_name = fullfile(folder,'FRET Correct Images',['cna_' fr{i}]);
    if strcmpi(FRETeff,'y')
        eff_name = fullfile(folder,'FRET Correct Images',['eff_' fr{i}]);
        dpa_name = fullfile(folder,'FRET Correct Images',['dpa_' fr{i}]);
    end
    
    % Write output images
    imwrite2tif(iaa,[],iaa_name,'single');
    imwrite2tif(idd,[],idd_name,'single');
    imwrite2tif(fc,[],fc_name,'single');
    imwrite2tif(nafc,[],nafc_name,'single');
    if strcmpi(FRETeff,'y')
        imwrite2tif(eff,[],eff_name,'single');
        imwrite2tif(dpa,[],dpa_name,'single');
    end
end

end

%--------------------------------------------------------------------------
% SUBFUNCTIONS:

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
