%% toonCat_step6_getCatSelectivity.m %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% This script generates disk ROIs from functional ROIs and computes the
% mean selectivity for a given contrast within the disk ROI. Functional
% ROIs in each individual must already be defined.

close all;
clear all;

%% Setup
% 0.Pathing
share_prefix = '/share/kalanit';
oak_prefix = '/oak/stanford/groups';
 % share_prefix = '/Volumes';
 % oak_prefix = '/Volumes';

% 0.Toolboxes
addpath(genpath('/share/kalanit/software/vistasoft/')); 
addpath(genpath(fullfile(oak_prefix, 'kalanit/biac2/kgs/projects/Kids_AcrossYears/FMRI/Toonotopy/code/')));

% 1.Subjects
% Initialize the sessionLists.
sessionLists_vista_FS;

% Directory
exptDir = fullfile(oak_prefix,'kalanit/biac2/kgs/projects/Kids_AcrossYears/FMRI/Localizer/data_toonCat');

% Select ROIs
hemis = {'rh','lh'};
% toonCatROIs = {'pFus_faces_toon','mFus_faces_toon','IOG_faces_toon_JC',...
%     'pOTS_words_toon','mOTS_words_toon',...
%     'OTS_bodies_toon','CoS_places_toon',...
%     'pSTS_faces_toon_JC','ITG_limbs_toon_JC', 'LOS_limbs_toon_JC','MTG_limbs_toon_JC',...
%     'IPS_places_toon_JC','MOG_places_toon_JC'};
toonCatROIs = {'pSTS_faces_adultAvg_probMap_toonCat','MTG_limbs_adultAvg_probMap_toonCat'}

% Select subjects
subs = sessions.catAll;
%% Create disk ROIs and transform to inplane
ROIsize = 10; % mm; choose either 5 or 10

toonCat_createDiskROI(ROIsize, toonCatROIs, hemis, subs)

%% Check that they've been transfered to mrVista

toonCat_roiCheck_mrVista(fullfile(oak_prefix, 'kalanit/biac2/kgs/projects/Kids_AcrossYears/FMRI/Localizer/data_toonCat/'), ...
    fullfile(oak_prefix,'kalanit/biac2/kgs/projects/Kids_AcrossYears/FMRI/Localizer/','results_toonCat'),...
    sessions.catAll, hemis,'KidsTeensAdults', toonCatDiskROIs, '10mm')


%% Compute mean selectivity for each ROI
% Pick runs for each subject
listRuns = [1 2 3];
%toonCatDiskROIs = {'pFus_faces_toon_5mm','mFus_faces_toon_5mm','IOG_faces_toon_JC_5mm','pOTS_words_toon_5mm','mOTS_words_toon_5mm','OTS_bodies_toon_5mm','CoS_places_toon_5mm','pSTS_faces_toon_JC_5mm','ITG_limbs_toon_JC_5mm', 'LOS_limbs_toon_JC_5mm','MTG_limbs_toon_JC_5mm','IPS_places_toon_JC_5mm','MOG_places_toon_JC_5mm'};
%toonCatDiskROIs = {'pFus_faces_toon_10mm','mFus_faces_toon_10mm','IOG_faces_toon_JC_10mm','pOTS_words_toon_10mm','mOTS_words_toon_10mm','OTS_bodies_toon_10mm','CoS_places_toon_10mm','pSTS_faces_toon_JC_10mm','ITG_limbs_toon_JC_10mm', 'LOS_limbs_toon_JC_10mm','MTG_limbs_toon_JC_10mm','IPS_places_toon_JC_10mm','MOG_places_toon_JC_10mm'};
toonCatDiskROIs = {'pSTS_faces_adultAvg_probMap_toonCat_10mm','MTG_limbs_adultAvg_probMap_toonCat_10mm'}
toonCat_computeMeanROISelectivity(toonCatDiskROIs, hemis, subs, listRuns)
