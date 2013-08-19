% Test Main Script for Blob Analysis

close all
clear
clc

param.sourcefolder = '061313 VinTS FRET'; % CHANGE THIS

% % MATCH ALL REGULAR EXPRESSIONS
DonorOnly_Acceptor = file_search('Teal_\d+_w1Venus.TIF',param.sourcefolder);
DonorOnly_Donor= file_search('Teal_\d+_w3Teal.TIF',param.sourcefolder);
DonorOnly_FRET = file_search('Teal_\d+_w2TVFRET.TIF',param.sourcefolder);
bkgAcceptor = file_search('Bkg_\d+_w1Venus.TIF',param.sourcefolder);
bkgDonor = file_search('Bkg_\d+_w3Teal.TIF',param.sourcefolder);
bkgFRET = file_search('Bkg_\d+_w2TVFRET.TIF',param.sourcefolder);
AcceptorOnly_Acceptor = file_search('Venus_\d+_w1Venus.TIF',param.sourcefolder);
AcceptorOnly_Donor = file_search('Venus_\d+_w3Teal.TIF',param.sourcefolder);
AcceptorOnly_FRET = file_search('Venus_\d+_w2TVFRET.TIF',param.sourcefolder);

param.dthres = 1000;
param.athres = 1000;
param.bit = 16; 
param.width = 100;
param.avg = 50;
param.outname = '061313_Katy'; % CHANGE THIS
param.destfolder = param.sourcefolder; 

% param.nobkgd = 0; % CHOOSE IF YOU HAVE BKG FILES
% param.nobkgd = 1; % CHOOSE IF YOU DON'T HAVE BKG FILES
param.nozero = 0;
param.ocimg = 0;

%IF YOU HAVE BKG FILES:
% fret_bledth(DonorOnly_Acceptor,DonorOnly_Donor,DonorOnly_FRET,bkgAcceptor,...
%     bkgDonor,bkgFRET,AcceptorOnly_Acceptor,AcceptorOnly_Donor,AcceptorOnly_FRET,param)

% IF YOU DON'T HAVE BKG FILES:    
% fret_bledth(DonorOnly_Acceptor,DonorOnly_Donor,DonorOnly_FRET,...
%     AcceptorOnly_Acceptor,AcceptorOnly_Donor,AcceptorOnly_FRET,param)
 
file = param.outname;
param.imin = [7000 7000 -10000]; % CHANGE THIS BASED ON BLEEDTHROUGH CURVE
param = rmfield(param,'outname');
param.donor_norm = 0;
param.double_norm = 0;
param.leave_neg = 1;
param.ocimg = 1;

% REPEAT FOR OTHER EXPERIMENTAL FILES (EX. VINTL, VINVENUS, ETC)
exp_Acceptor_1 = file_search('VinTS_\d+_w1Venus.TIF',param.sourcefolder);
exp_Donor_1 = file_search('VinTS_\d+_w3Teal.TIF',param.sourcefolder);
exp_FRET_1 = file_search('VinTS_\d+_w2TVFRET.TIF',param.sourcefolder);

% IF YOU HAVE BKG FILES:
% fret_correct(exp_Acceptor_1,exp_Donor_1,exp_FRET_1,{['nlabt_' file]},{['nldbt_' file]},...
%     bkgAcceptor,bkgDonor,bkgFRET,param)

% IF YOU DON'T HAVE BKG FILES:
% fret_correct(exp_Acceptor_1,exp_Donor_1,exp_FRET_1,{['nlabt_' file]},{['nldbt_' file]},param)

imin = [0 0 -1000];
% fret_img_avg_2('cna_',imin,param.destfolder);

% fa_gen('bsffa_VinTS\w*.tif',[25,250,10],param.destfolder)

fname = 'VinTS';
keywords.outname = 'VinTS_061313';
keywords.sizemin = 5; % CAN CHANGE
keywords.sizemax = 10000; % CAN CHANGE
keywords.folder = param.destfolder;
% blob_analyze2({['cna_' fname '\w*.TIF'],['bsffd_' fname '\w*.TIF'],...
%     ['bsffa_' fname '\w*.TIF'],['fa_bsffa_' fname '\w*.TIF']},keywords)