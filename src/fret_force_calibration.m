function fret_force_calibration(eff_img_name,SaveParams)
% PURPOSE: A program to convert FRET efficiency images into force images
% based on an input calibration curve in SaveParams structure
% (SaveParams.eff = FRET efficiency, SaveParams.force = force)

%--------------------------------------------------------------------------

% Created 1/21/15 by Andrew LaCroix

%--------------------------------------------------------------------------

% INPUTS:

% inputs that are required to run the function are as follows:
% eff_img_name - base name for the FRET efficiency images a FRET sample
% FA_img_name - base name for the corresponding FA mask image

% SaveParams will be a structure containing a field for at least the following parameters:
% cal_curve = force - FRET efficiency calibration curve
% Column 1 = force (pN)
% Column 2 = FRET efficiency

%--------------------------------------------------------------------------

% OUTPUTS:

% Program writes out
% Force pictures (in pN)

%--------------------------------------------------------------------------

%% Visualize FRET efficiency distribution in all FAs for VinTL
% Only happens once, when SaveParams does not yet contain
% SaveParams.zero_force_offset saved to it
if ~isfield(SaveParams,'zero_force_offset')
    all_TLeff_imgs = file_search(['eff_\w+TL\w+' SaveParams.FRETchannel '.TIF'],SaveParams.folder);
    all_TLFA_imgs = file_search(['fa_\w+TL\w+' SaveParams.Achannel '.TIF'],SaveParams.folder);
    nTL = length(all_TLeff_imgs);
    effvalues = 1;
    for i = 1:nTL
        eff = double(imread(all_TLeff_imgs{i}));
        FA = double(imread(all_TLFA_imgs{i}));
        FA(FA>0) = 1; % make FA img binary
        eff = eff.*FA; % isolate pixels only inside FAs
        eff(isnan(eff)) = 0;
        effvalues = vertcat(effvalues,nonzeros(eff)); % capture all values for TL FRET efficiency for subsequent histographical analysis
    end
    effvalues = effvalues(2:end);
    SaveParams.zero_force_eff_offset = median(effvalues)-0.2396;
    disp(SaveParams.zero_force_eff_offset);
    save(fullfile(pwd,SaveParams.folder, ['SaveParams_' SaveParams.folder '.mat']),'-struct','SaveParams');
end

%% Calculate force on each input image
eff_img = file_search(eff_img_name,SaveParams.folder);

for i = 1:length(eff_img)
    % Get fluorescent images
    eff = double(imread(fullfile(SaveParams.folder,eff_img{i})));
    
    % Apply above-generated FRET efficiency offset to make FRET
    % efficiencies match calibration curve
    eff = eff - SaveParams.zero_force_eff_offset;
    
    % Apply limits to FRET efficiency data so it works with calibration
    % curve
    eff(eff<0.0039) = 0.0039;
    eff(eff>0.2396) = 0.2396;
    
    % Following calibration curve from Grashoff Nature 2010
    force = interp1(SaveParams.cal_curve(:,2),SaveParams.cal_curve(:,1),eff);
    
    % Name and write output images
    force_name = fullfile(SaveParams.folder,['force_' eff_img{i}(5:end)]);
    imwrite2tif(force,[],force_name,'single');
end

end
