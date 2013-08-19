% Test Main Script for Blob Analysis

close all
clear
clc

param.sourcefolder = 'limited_images'; % CHANGE THIS

param.dthres = 1000;
param.athres = 1000;
param.bit = 16; 
param.width = 100;
param.avg = 50;
param.outname = '060713_Katy_nobkg'; % CHANGE THIS
param.destfolder = 'results'; 
param.ocimg = 0;
param.nobkgd = 1;
param.nozero = 0;

% MATCH ALL REGULAR EXPRESSIONS
DonorOnly_Acceptor = file_search('crop_Teal_PXN\d+_w1Venus.TIF',param.sourcefolder);
DonorOnly_Donor= file_search('crop_Teal_PXN\d+_w3Teal.TIF',param.sourcefolder);
DonorOnly_FRET = file_search('crop_Teal_PXN\d+_w2TVFRET.TIF',param.sourcefolder);
% bkgAcceptor = file_search('crop_Bkg_PXN\d+_w1Venus.TIF',param.sourcefolder);
% bkgDonor = file_search('crop_Bkg_PXN\d+_w3Teal.TIF',param.sourcefolder);
% bkgFRET = file_search('crop_Bkg_PXN\d+_w2TVFRET.TIF',param.sourcefolder);
AcceptorOnly_Acceptor = file_search('crop_Venus_PXN\d+_w1Venus.TIF',param.sourcefolder);
AcceptorOnly_Donor = file_search('crop_Venus_PXN\d+_w3Teal.TIF',param.sourcefolder);
AcceptorOnly_FRET = file_search('crop_Venus_PXN\d+_w2TVFRET.TIF',param.sourcefolder);

param.outname = '060713Crop_Katy_nobkg'; % CHANGE THIS
param.destfolder = 'results'; 

if (not(exist(param.destfolder,'dir')))
    mkdir(param.destfolder);
end

param.nobkgd = 1;
% figure;
  
fret_bledth(DonorOnly_Acceptor,DonorOnly_Donor,DonorOnly_FRET,...
    AcceptorOnly_Acceptor,AcceptorOnly_Donor,AcceptorOnly_FRET,param)

param.imin = [7000 7000 -10000]; % CHANGE THIS BASED ON BLEEDTHROUGH CURVE
param = rmfield(param,'outname');
param.donor_norm = 0;
param.double_norm = 0;
param.leave_neg = 1;
param.ocimg = 1;

exp_Acceptor_1 = file_search('crop_VinTS_PXN\d+_w1Venus.TIF',param.sourcefolder);
exp_Donor_1 = file_search('crop_VinTS_PXN\d+_w3Teal.TIF',param.sourcefolder);
exp_FRET_1 = file_search('crop_VinTS_PXN\d+_w2TVFRET.TIF',param.sourcefolder);

fret_correct(exp_Acceptor_1,exp_Donor_1,exp_FRET_1,{0.19},{0.94},param)

exp_Acceptor_2 = file_search('crop_VinTL_PXN\d+_w1Venus.TIF',param.sourcefolder);
exp_Donor_2 = file_search('crop_VinTL_PXN\d+_w3Teal.TIF',param.sourcefolder);
exp_FRET_2 = file_search('crop_VinTL_PXN\d+_w2TVFRET.TIF',param.sourcefolder);

fret_correct(exp_Acceptor_2,exp_Donor_2,exp_FRET_2,{0.19},{0.94},param)

imin = [0 0 -1000];
% fret_img_avg_2('cna_',imin,param.destfolder)