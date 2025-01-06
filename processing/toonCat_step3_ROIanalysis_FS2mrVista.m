%% toonCat_step3_ROIanalysis_FS2mrVista.m %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 3 in toonotopy-category selectivity development project. After
% running step 1 and step 2, we run this script analyzes all subjects as a
% group. Be sure to determine the group you are interested in (kidsTeens,
% kids, adults, all) - you'll likely need to run this script multiple times  
% with the group changed to analyze groups separately! This will output the
% dataframes that will be used to create the figures, which will be done in
% R markdown.
%
% REQUIRED: FS labelsfrom toonCat_step2_drawToonROI_FS, mrVista 3D
% anatomy,subject/session lists
%
% In this script:
%
% 1. Setup
% 2. Label prep
% 3. Convert FS Labels -> mrVista
% 4. (Optional) Check for ROIs
% 5. Extract pRF data
% 6. Plot pRF centers
% 7. Plot VFC
% 8. Create dataframes
% 9. Size v Ecc Analysis
%
%
% JKY Nov 2023
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all

%% 0. Pathing
% Change path prefixes depending on code access

% Server
share_prefix = '/share/kalanit';
oak_prefix = '/oak/stanford/groups';

% % Mounted
share_prefix = '/Volumes';
oak_prefix = '/Volumes';

%% 0. Toolboxes
addpath(genpath(fullfile(oak_prefix, 'kalanit/biac2/kgs/projects/Kids_AcrossYears/FMRI/Toonotopy/code')))
addpath(genpath(fullfile(share_prefix, 'biac2/kgs/projects/toonAtlas/code/knkutils/io')))

%% 1. Setup
% Initialize the sessionLists. This creates
% a structure with all of the subjects grouped by age and by either mrVista
% or FreeSurfer for reference throughout this code.

sessionLists_vista_FS

% Chose group for file names
%group = 'KidsTeens';
group = 'KidsTeensAdults';
% group = 'Adults';


% Directory
exptDir = fullfile(oak_prefix,'kalanit/biac2/kgs/projects/Kids_AcrossYears/FMRI/Toonotopy/');

% Variables
hemis = {'rh','lh'};
atlas = 'adultAvg_probMap_toonCat'; % toon or wang or toon_JC or adults_avg or adultAvg_probMap_toonCat

% Which ROIs do we need to convert?
% toonCatROIs: combined ROIs, individual ROIs, category ROIs
%toonCatROIs = {'V1','V2','V3','hV4','VO','PHC'}; 
%toonCatROIs = {'pFus_faces','mFus_faces','OTS_bodies','pOTS_words','mOTS_words','CoS_places'};%toon
%toonCatROIs = {'IOG_faces','ITG_limbs','LOS_limbs','IPS_places','MOG_places'}; %toon_JC
toonCatROIs = {'pSTS_faces','MTG_limbs'} %adultAvg_probMap_toonCat
%toonCatROIs = {'FG1', 'FG2', 'FG3', 'FG4'};
%% 2. Label preparation (OPTIONAL depending on ROIs)
% Merge multi-component labels
% For ROIs with multiple components (dorsal, ventral, 1, 2) we combine them
% here for analysis if they haven't already been drawn as one.

% List of label pairs and their output names
% ex. {label1, label2, outputName}
labelPairs = {
    {'IPSl_places', 'IPSm_places', 'IPS_places'}
    {'mSTS_faces', 'pSTS_faces', 'STS_faces'}
    %{'V1d', 'V1v', 'V1'},
    % {'V2d', 'V2v', 'V2'},
    %{'V3d', 'V3v', 'V3'}%,
    % {'PHC1', 'PHC2', 'PHC'},
    %{'VO1', 'VO2', 'VO'}
};

toon_mergeLabels(fullfile(oak_prefix, 'kalanit/biac2/kgs/anatomy/freesurferRecon/Kids_AcrossYears/'), sessions.fsAll, hemis, labelPairs, atlas)

% Convert category localizer labels (only if you are using average labels)
% Labels previously drawn in other templates must be converted to the
% appropriate freesurfer surface
toon_convertfLOCLabel_surf2surf

%% 3. Convert Freesurfer labels to mrVista
% We do this because we are currently unable to pull from the entire
% cortical ribbon in freesurfer. Subjects might have multiple sessions, so
% we can run this separately by session number.

% % KIDS
% % % session 1
subs1 = {'AW05','SD06','ENK05','CLC06','RJ09','CS11','GEJA09','MDT09','DAPA10','STM10','OS12'};
sess1 = 1;
convertFreeSurferLabel2mrvista(subs1,sess1,hemis,toonCatROIs,atlas,'KidsTeens')

% % % session 2
subs2 = {'ED07','ENK05','INW06','RJ09','AOK07','DAPA10','CGSA11'};
sess2 = 2;
convertFreeSurferLabel2mrvista(subs2,sess2,hemis,toonCatROIs,atlas,'KidsTeens')

% ADULTS
subs = {'CR24','CS22','EM','ES','GB23','JEW23','JP23','JW','KM25','MG','MJH25','MN','MW23','MZ23','NAV22','NC24','SP','ST25','TH','TL24','JG24','MSH28','KG22','VN26','DRS22','MBA24','DF'};
sess = 1;
convertFreeSurferLabel2mrvista(subs,sess,hemis,toonCatROIs,atlas,'Adults')

%% 4. ROI checks (Optional)
% Here we can output dataframes of which ROIs we've converted and where
% they're located. We'll want to first make sure they're drawn (in
% freesurfer). Then we can check to see if they've been converted to
% mrVista (step 1 of this script) so that we can extract parameters!

% Check that you've drawn the labels in Freesurfer
 toonCat_roiCheck_freesurfer(fullfile(oak_prefix, 'kalanit/biac2/kgs/anatomy/freesurferRecon/Kids_AcrossYears/'), ...
     fullfile(exptDir,'results/jewelia/'),...
    sessions.fsAll, hemis, 'KidsTeensAdults', toonCatROIs, atlas)

% Check that they've been transfered to mrVista
toonCat_roiCheck_mrVista(fullfile(oak_prefix, 'kalanit/biac2/kgs/projects/Kids_AcrossYears/FMRI/Toonotopy/data/'), ...
    fullfile(exptDir,'results/jewelia/'),...
    sessions.vistaAll, hemis,'KidsTeensAdults', toonCatROIs, atlas)

%% 5. Get the pRF data
% This step pulls and stores measures from the retinotopic model for
% plotting centers and coverage for ALL subjects; extracts from mrVista, so
% use mrVista session indices
sessList = sessions.vistaAll
group = 'KidsTeensAdults'
% sessList = sessions.vistaKidsTeens
% group = 'KidsTeens'
% sessList = sessions.vistaAdults
% group = 'Adults'

atlas = 'toon';toonCatROIs = {'pFus_faces','mFus_faces','OTS_bodies','pOTS_words','mOTS_words','CoS_places'};%toon
%atlas = 'toon_JC';toonCatROIs = {'IOG_faces','ITG_limbs','LOS_limbs','IPS_places','MOG_places'}; %toon_JC
%atlas = 'adultAvg_probMap_toonCat';toonCatROIs = {'pSTS_faces','MTG_limbs'} %adultAvg_probMap_toonCat

% What's the experiment name? You can also include the version of the
% dataframe if you are re-running. This is added to the fileName
exptName = 'toonCat'
% ROI Indices (set this to match your ROI list/index so that the df's come
% out in the correct order)

% V1 = 1; V2 = 2; V3 = 3; hV4 = 4; VO = 5; PHC = 6;
% pFus_faces = 7; pOTS_words = 8; CoS_places = 9; mFus_faces = 10; OTS_bodies = 11; mOTS_words = 12;
% pFus_kubotaMPM = 13; pOTS_kubotaMPM = 14; PPA_kubotaMPM = 15; mFus_kubotaMPM = 16; OTS_kubotaMPM = 17; mOTS_kubotaMPM = 18;

% IOG_faces = 1; pSTS_faces = 2; mSTS_faces = 3; STS_faces = 4; ITG_limbs = 5; LOS_limbs = 6; 
% MTG_limbs = 7; IPSl_places = 8; IPSm_places = 9; IPS_places = 10; MOG_places = 11; 

pFus_faces = 1; mFus_faces = 2; OTS_bodies = 3; pOTS_words = 4; mOTS_words = 5; CoS_places = 6;
%IOG_faces = 1; ITG_limbs = 2; LOS_limbs = 3; IPS_places = 4; MOG_places = 5;
%pSTS_faces = 1; MTG_limbs = 2;

% Get metrics for centers, size, eccentricity, sigma, variance explained
toonCat_getpRFData(sessList,hemis,group,exptDir,exptName,atlas,toonCatROIs) 

% Get metrics for coverage
toonCat_calcAveragedCoverage(sessList,hemis,group,exptDir,exptName,atlas,toonCatROIs)


% Get proportion of voxels with VE 20%
toonCat_getVoxelsVE(sessList,hemis,group,exptDir,exptName,atlas,toonCatROIs)

close all
%% 6. Plot pRF centers
% Plots all pRF centers for all subjects for each of the ROIs. This may
% beed to be done separately for each group, so you might want to change
% the sessList and group variables.
% sessList = sessions.vistaKidsTeens
% group = 'KidsTeens'
sessList = sessions.vistaAdults
group = 'Adults'

toonCat_plotAllCenters(sessList,hemis,group,exptDir,exptName,atlas,toonCatROIs)

close all
%% 7. Plot pRF coverage
% Plot average coverage of all subjects for each ROI. This may need to be
% done separately for each group, so you might want to change the sessList
% and group variables!
sessList = sessions.vistaKidsTeens
group = 'KidsTeens'
% sessList = sessions.vistaAdults
% group = 'Adults'

% Which ROIs do we need to convert?
%atlas = 'toon';toonCatROIs = {'pFus_faces','mFus_faces','OTS_bodies','pOTS_words','mOTS_words','CoS_places'};%toon
%atlas = 'toon_JC';toonCatROIs = {'IOG_faces','ITG_limbs','LOS_limbs','IPS_places','MOG_places'}; %toon_JC
atlas = 'adultAvg_probMap_toonCat'; toonCatROIs = {'pSTS_faces','MTG_limbs'} %adultAvg_probMap_toonCat


toonCat_plotAveragedCoverage(sessList,hemis,group,exptDir,exptName,atlas,toonCatROIs)

close all
%% 8. Get csv's for plotting in R
% Note: you probably want to run these with all your subjects (kids +
% adults) so that they're in one dataframe. Also note that the proportion
% for DF1 includes NaN values and the proportions for DF2 + DF3 are
% thresholded by sigma, so the NaN values are dropped and the number of
% voxels is smaller. For recreating Fig1C with the wang atlas, you will
% only need DF1
sessList = sessions.vistaAll
group = 'KidsTeensAdults'

% Parameters (see parameters in data extraction step to match)
ve_cutoff = .20;
fieldRange = 20;
fieldRange2plot = 20;
norm = 0;
thresh = 10;

% Results Directory (within exptDir)
resultsDir = 'results/jewelia';

%atlas = 'toon';toonCatROIs = {'pFus_faces','mFus_faces','OTS_bodies','pOTS_words','mOTS_words','CoS_places'};%toon
%atlas = 'toon_JC';toonCatROIs = {'IOG_faces','ITG_limbs','LOS_limbs','IPS_places','MOG_places'}; %toon_JC
atlas = 'adultAvg_probMap_toonCat';toonCatROIs = {'pSTS_faces','MTG_limbs'} %adultAvg_probMap_toonCat

% DF1: Get csv for FWHM, proportions, centers
toonCat_getFWHMCoV_df(sessList,hemis,group,exptDir,exptName,atlas,toonCatROIs,resultsDir,ve_cutoff, fieldRange,fieldRange2plot,norm,thresh) % this gets the CoM and FWHM for the coverage
toonCat_getFWHMCenters_df(sessList,hemis,group,exptDir,exptName,atlas,toonCatROIs,resultsDir,ve_cutoff, fieldRange,fieldRange2plot,norm,thresh) % this gets the CoM and FWHM for the pRF centers

%% 9. Plot size vs. eccentricity slopes (Optional, not used in FYP)
% Get size versus eccentricity data (based off of Jesse's loop code)
% We will plot this in R to account for random/fixed intercepts etc.

% Set threshold variables here:
vethresh = 0.20; 
fieldRange = 20; %40;
eccthresh = [0.5, fieldRange - 0.5]; %avoid edging effects
sigthresh = [0.002, 20]; 
voxthresh = 10; %min number of voxels

% Define the ROI list. We defined bilaterally and each hemisphere in the
% event a subject only has one hemisphere's ROI
roiNames = {'rh.V1_toon.mat' 'rh.V2_toon.mat' 'rh.V3_toon.mat' 'rh.hV4_toon.mat' 'rh.VO_toon.mat' 'rh.PHC_toon.mat' 'rh.pFus_faces_toon.mat' 'rh.pOTS_words_toon.mat' 'rh.CoS_places_toon.mat' 'rh.mFus_faces_toon.mat' 'rh.OTS_bodies_toon.mat' 'rh.mOTS_words_toon.mat' 'rh.pFus_kubotaMPM_toon.mat' 'rh.pOTS_kubotaMPM_toon.mat' 'rh.PPA_kubotaMPM_toon.mat' 'rh.mFus_kubotaMPM_toon.mat' 'rh.OTS_kubotaMPM_toon.mat' 'rh.mOTS_kubotaMPM_toon.mat' 'lh.V1_toon.mat' 'lh.V2_toon.mat' 'lh.V3_toon.mat' 'lh.hV4_toon.mat' 'lh.VO_toon.mat' 'lh.PHC_toon.mat' 'lh.pFus_faces_toon.mat' 'lh.pOTS_words_toon.mat' 'lh.CoS_places_toon.mat' 'lh.mFus_faces_toon.mat' 'lh.OTS_bodies_toon.mat' 'lh.mOTS_words_toon.mat' 'lh.pFus_kubotaMPM_toon.mat' 'lh.pOTS_kubotaMPM_toon.mat' 'lh.PPA_kubotaMPM_toon.mat' 'lh.mFus_kubotaMPM_toon.mat' 'lh.OTS_kubotaMPM_toon.mat' 'lh.mOTS_kubotaMPM_toon.mat'};
%roiNames = {'rh.IOG_faces_toon_JC.mat' 'rh.pSTS_faces_toon_JC.mat' 'rh.mSTS_faces_toon_JC.mat' 'rh.ITG_limbs_toon_JC.mat' 'rh.LOS_limbs_toon_JC.mat''rh.MTG_limbs_toon_JC.mat' 'rh.IPSl_places_toon_JC.mat' 'rh.IPSm_places_toon_JC.mat' 'rh.IPS_places_toon_JC.mat' 'rh.MOG_places_toon_JC.mat''lh.IOG_faces_toon_JC.mat' 'lh.pSTS_faces_toon_JC.mat' 'lh.mSTS_faces_toon_JC.mat' 'lh.ITG_limbs_toon_JC.mat' 'lh.LOS_limbs_toon_JC.mat''lh.MTG_limbs_toon_JC.mat' 'lh.IPSl_places_toon_JC.mat' 'lh.IPSm_places_toon_JC.mat' 'lh.IPS_places_toon_JC.mat''lh.MOG_places_toon_JC.mat'};

resultsDir = 'results/jewelia';

% ROI indices
% right hemisphere
V1 = 1; V2 = 2; V3 = 3; hV4 = 4; VO = 5; PHC = 6;
pFus_faces = 7; pOTS_words = 8; CoS_places = 9; mFus_faces = 10; OTS_bodies = 11; mOTS_words = 12;
pFus_kubotaMPM = 13; pOTS_kubotaMPM = 14; PPA_kubotaMPM = 15; mFus_kubotaMPM = 16; OTS_kubotaMPM = 17; mOTS_kubotaMPM = 18;

% % % left hemisphere
V1 = 19; V2 = 20; V3 = 21; hV4 = 22; VO = 23; PHC = 24;
pFus_faces = 25; pOTS_words = 26; CoS_places = 27; mFus_faces = 28; OTS_bodies = 29; mOTS_words = 30;
pFus_kubotaMPM = 31; pOTS_kubotaMPM = 32; PPA_kubotaMPM = 33; mFus_kubotaMPM = 34; OTS_kubotaMPM = 35; mOTS_kubotaMPM = 36;

% IOG_faces = 1; pSTS_faces = 2; mSTS_faces = 3; STS_faces = 4; ITG_limbs = 5; LOS_limbs = 6; 
% MTG_limbs = 7; IPSl_places = 8; IPSm_places = 9; IPS_places = 10; MOG_places = 11; 
% IOG_faces = 12; pSTS_faces = 13; mSTS_faces = 14; STS_faces = 15; ITG_limbs = 16; LOS_limbs = 17; 
% MTG_limbs = 18; IPSl_places = 19; IPSm_places = 20; IPS_places = 21; MOG_places = 12; 


% This step extracts all the data and organizes it - need to check how they
% do the slopes/intercepts here
roiNames = {'rh.V1_toon' 'rh.V2_toon' 'rh.V3_toon'}
rhroiNames = {'rh.V1_toon' 'rh.V2_toon' 'rh.V3_toon' 'rh.hV4_toon' 'rh.VO_toon' 'rh.PHC_toon' 'rh.pFus_faces_toon' 'rh.pOTS_words_toon' 'rh.CoS_places_toon' 'rh.mFus_faces_toon' 'rh.OTS_bodies_toon' 'rh.mOTS_words_toon' 'rh.pFus_kubotaMPM_toon' 'rh.pOTS_kubotaMPM_toon' 'rh.PPA_kubotaMPM_toon' 'rh.mFus_kubotaMPM_toon' 'rh.OTS_kubotaMPM_toon' 'rh.mOTS_kubotaMPM_toon'};
lhroiNames = {'lh.V1_toon' 'lh.V2_toon' 'lh.V3_toon' 'lh.hV4_toon' 'lh.VO_toon' 'lh.PHC_toon' 'lh.pFus_faces_toon' 'lh.pOTS_words_toon' 'lh.CoS_places_toon' 'lh.mFus_faces_toon' 'lh.OTS_bodies_toon' 'lh.mOTS_words_toon' 'lh.pFus_kubotaMPM_toon' 'lh.pOTS_kubotaMPM_toon' 'lh.PPA_kubotaMPM_toon' 'lh.mFus_kubotaMPM_toon' 'lh.OTS_kubotaMPM_toon' 'lh.mOTS_kubotaMPM_toon'};
lhroiNames_subset = {'lh.V1_toon' 'lh.V2_toon' 'lh.V3_toon' 'lh.hV4_toon' 'lh.VO_toon' 'lh.pOTS_words_toon' 'lh.pFus_faces_toon' 'lh.mOTS_words_toon' 'lh.OTS_bodies_toon' 'lh.mFus_faces_toon' 'lh.CoS_places_toon'};
rhlatRoiNames = {'rh.IOG_faces_toon_JC' 'rh.pSTS_faces_toon_JC' 'rh.mSTS_faces_toon_JC' 'rh.STS_faces_toon_JC' 'rh.ITG_limbs_toon_JC' 'rh.LOS_limbs_toon_JC' 'rh.MTG_limbs_toon_JC' 'rh.IPSl_places_toon_JC' 'rh.IPSm_places_toon_JC' 'rh.IPS_places_toon_JC' 'rh.MOG_places_toon_JC'};
lhlatRoiNames = {'lh.IOG_faces_toon_JC' 'lh.pSTS_faces_toon_JC' 'lh.mSTS_faces_toon_JC' 'lh.STS_faces_toon_JC' 'lh.ITG_limbs_toon_JC' 'lh.LOS_limbs_toon_JC' 'lh.MTG_limbs_toon_JC' 'lh.IPSl_places_toon_JC' 'lh.IPSm_places_toon_JC' 'lh.IPS_places_toon_JC' 'lh.MOG_places_toon_JC'};

exptName = 'toonCat';
atlas = 'toon'
%toonCat_plotSizevEcc(sessList,hemis,group,exptDir,exptName,atlas,toonCatROIs,resultsDir,vethresh,sigthresh,eccthresh,voxthresh) % line data by hemi
ageFile = 'subject_ages_mrVista.csv' ;

% for h=1:length(hemis)
%     cd(fullfile('/oak/stanford//groups/kalanit/biac2/kgs/projects/Kids_AcrossYears/FMRI/Toonotopy/results/jewelia/'))
%     lineData = [hemis{h} '.ve', num2str(vethresh*100), 'sigthresh', num2str(sigthresh(2)), 'eccen', num2str(round(eccthresh(2))), '_EccVsSigma_lineData_10mmcontrol_' exptName '_' group '_' atlas 'ROIs.mat'];
%     addAgeSessionToLineData(lineData, ageFile)
% end

lineData = 'rh.ve20sigthresh20eccen20_EccVsSigma_lineData_10mmcontrol_toonCat_KidsTeensAdults_toonROIs_with_age_session.mat'

% toonCat_loopSigmavsEcc(sessList,group,exptDir,exptName,atlas,roiNames,resultsDir,vethresh, eccthresh, sigthresh, voxthresh) % all hemi line data
% 
% % Transform data into a dataframe usable in R (choose one)
% %toonCat_getSizeEccVertex_df(sessList,group,exptDir,exptName,atlas,resultsDir) % vertex format
% %toonCat_getSizeEccLineFits_df(sessList,group,exptDir,exptName,atlas,resultsDir) % line fits
% toonCat_getSizeEccLoopSlopeInt_df(sessList,group,exptDir,exptName,atlas,resultsDir) % slope-intercepts

%% Now, you can move to the individual figure plots in R!    