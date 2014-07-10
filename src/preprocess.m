function preprocess(channels,parameters_file,folder,varargin)
% This function allows one to perform preprocessing steps that are required
% for any experiment. Just type in the channels you took pictures in and it
% will output perfectly overlayed images. The structure PreParams depends 
% on your experimental conditions (magnification, temperature, live vs fixed, 
% etc. and comes from the function PreParams_gen.m

% Brief overview of steps
% (1) X-Y Translational Registration
% (2) Radial Distortion Correction
% (3) Cropping to eliminate vignetting
% (4) Darkfield subtraction and shading correction (flatfielding)
% (5) Background subtraction

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Setup and Verify Inputs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_p = inputParser;
i_p.addRequired('channels',@iscell);
i_p.addRequired('parameters_file',@(x)exist(x,'file') == 2);
i_p.addRequired('folder',@(x)exist(x,'dir') == 7);

i_p.addParamValue('status_messages',false,@(x)islogical(x));

i_p.parse(channels,parameters_file,folder);

PreParams = load(parameters_file);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Main Program
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i = 1:length(channels)
    imgNames = file_search(['\w+' channels{i} '.TIF'],folder);
    reg_x = PreParams.(channels{i}).xshift;
    reg_y = PreParams.(channels{i}).yshift;
    rad_k = PreParams.(channels{i}).k;
    rad_ex = PreParams.(channels{i}).ex;
    dark = PreParams.(channels{i}).dark;
    shade = PreParams.(channels{i}).shade;
    
    if (i_p.Results.status_messages)
        fprintf('Starting on channel %s (%d/%d)\n',channels{i},i,length(channels));
    end
    
    for j = 1:length(imgNames)
        %Load images
        img = single(imread(fullfile(folder,imgNames{j})));
        %XY Registration
        sz = size(img);
        [y,x] = ndgrid(1:sz(1),1:sz(2));
        img = interp2(x,y,img,x-reg_x,y-reg_y);
        %Radial Correction
        img = lensdistort(img,rad_k,rad_ex,'ftype',5,'bordertype','fit');
        %Cropping to get rid of pixels outside the field of view after radial 
        %and XY translational corrections
        sz = size(img);
        crop = [round(0.05*sz(1)) round(0.05*sz(1)) round(0.9*sz(1)) round(0.9*sz(1))];
        img = imcrop(img,crop);
        %Darkfield subtraction + avg shade corrections both previously
        %registered, radially corrected and cropped
        img = img - dark;
        img = img./shade;
        %Background subtraction
        params.bin = 1;
        params.nozero = 0;
        img = bs_ff(img,params);
        %Write out as 32bit TIFs
        imwrite2tif(img,[],fullfile(folder,['pre_' imgNames{j}]),'single')
        if (i_p.Results.status_messages && any(j == round(linspace(1,length(imgNames),5))))
            fprintf('Done with image %d/%d\n',j,length(imgNames));
        end
    end
end

end

