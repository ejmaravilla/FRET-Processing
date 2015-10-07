function preprocess(parameters_file,folder,varargin)
% This function allows one to perform preprocessing steps that are required
% for any experiment. It will go through the potential imaging channels and
% will output perfectly overlayed images. The structure PreParams depends
% on your experimental conditions (magnification, temperature, live vs fixed,
% etc. and comes from the function PreParams_gen.m or from the pre-defined
% PreParams file that matches your experimental conditions.

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
i_p.addRequired('parameters_file',@(x)exist(x,'file') == 2);
i_p.addRequired('folder',@(x)exist(x,'dir') == 7);

i_p.addParamValue('status_messages',false,@(x)islogical(x)); %#ok<NVREPL>

i_p.parse(parameters_file,folder);

PreParams = load(parameters_file);

n = nargin;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Main Program
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
count = 0;
for channel = fieldnames(PreParams)';
    count = count+1;
    channel = channel{1};  %#ok<FXSET>
    imgNames = file_search(['.*w\d+' channel '.*.TIF$'],folder);
    if ~(isempty(imgNames))
        reg_x = PreParams.(channel).xshift;
        reg_y = PreParams.(channel).yshift;
        rad_k = PreParams.(channel).k;
        rad_ex = PreParams.(channel).ex;
        dark = PreParams.(channel).dark;
        shade = PreParams.(channel).shade;
        
        if (i_p.Results.status_messages)
            fprintf('Starting on channel %s.\n',channel);
        end
        
        for j = 1:length(imgNames)
            %Load images
            img = single(imread(fullfile(folder,imgNames{j})));
            %Darkfield subtraction before registration
            if all(size(img) == size(dark))
                img = img - dark;
                %XY Registration
                sz = size(img);
                [y,x] = ndgrid(1:sz(1),1:sz(2));
                img = interp2(x,y,img,x-reg_x,y-reg_y);
                %Radial Correction
                img = lensdistort(img,rad_k,rad_ex,'ftype',5,'bordertype','fit');
                %Cropping to get rid of pixels outside the field of view after radial
                %and XY translational corrections
                sz = size(img);
                crop = [round(0.0246*sz(1)) round(0.0246*sz(1)) round(0.9509*sz(1)) round(0.9509*sz(1))];
                img = imcrop(img,crop);
                %Avg shade corrections both previously registered, radially corrected and cropped
                img = img./shade;
                %Background subtraction
                params.bin = 1;
                params.nozero = 0;
                if n ==2
                    img = bs_ff(img,params);
                else
                    img = bs_ff(img,varargin{1}(count),params);
                end
                %Write out as 32bit TIFs
                imwrite2tif(img,[],fullfile(folder,'Preprocessed Images',['pre_' imgNames{j}]),'single')
                if (i_p.Results.status_messages && any(j == round(linspace(1,length(imgNames),5))))
                    fprintf('Done with image %d/%d\n',j,length(imgNames));
                end
            end
        end
    end
end

end