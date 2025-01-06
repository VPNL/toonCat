%% toonCat_step2_drawToonROIs_FS.m %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 2 in toonotopy-category selectivity development project. This script
% converts mrVista retinotopy maps into freesurfer and provides setup for
% drawing ROIs in Freeview. Copy into each subject's code directory
%
% REQUIRED: output (mrVista parameter maps) from toonCat_step1_mrV2FS, sub
% freesurfer recon
%
% In this script:
%
% 1. Setup
% 2. Convert parameter maps, mrVista -> FS
% 3. Create variance explained masks
% 4. (Optional) Create flatmaps
% 5. Create partially inflated FS views
% 6. Draw retinotopic ROIs
% 7. Convert ROIS, FS -> mrVista
% 8. (Optional) Take individual screenshots
%
% JKY Apr 2023
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all

%% 0. Pathing
% Change path prefixes depending on code access

% Server
% share_prefix = '/share/kalanit';
% oak_prefix = '/oak/stanford/groups';

% Mounted
share_prefix = '/Volumes';
oak_prefix = '/Volumes';

%% 0. Toolboxes
addpath(genpath(fullfile(oak_prefix, 'kalanit/biac2/kgs/projects/Kids_AcrossYears/FMRI/Toonotopy/code')))
addpath(genpath(fullfile(share_prefix, 'biac2/kgs/projects/toonAtlas/code/knkutils/io')))

%% 1. Setup
% Use setSessions_toonCat.m to setup the subject, session, and FreeSurfer
% directories

% setSessions information
subID = 'EM';
sessID = 1;
[sessions, fs_sessions] = setSessions_toonCat(subID, sessID);

% Create setup structure
setup.vistaDir = fullfile(oak_prefix, 'kalanit/biac2/kgs/projects/Kids_AcrossYears/FMRI/Toonotopy/data');
setup.fsDir = fullfile(oak_prefix, 'kalanit/biac2/kgs/anatomy/freesurferRecon/Kids_AcrossYears');
setup.subID = subID;
setup.fsSession = fs_sessions;
setup.vistaSession = sessions;
subjid = setup.fsSession;

% Set FreeSurfer Directory
setenv('SUBJECTS_DIR', setup.fsDir);

% Set output directory for freesurfer maps
if strcmp(setup.subID, setup.vistaSession)
    vistaDir = fullfile(setup.vistaDir, setup.subID); % adult
else
    vistaDir = fullfile(setup.vistaDir, setup.subID, setup.vistaSession); % kid
end
map_dir = fullfile(vistaDir, 'FreesurferFormat');

%% 2. Convert mrVista maps to FreeSurfer
% Convert retinotopy maps from step1 to .mgz files readable by FreeSurfer
% Note: lh.phase must be additionally adjusted to translate to the Freeview
% colorwheel (basically flip the color range)

% Select maps for both hemispheres
maps = {'eccen', 'phase', 'size', 'varexp'};
hemis = {'rh', 'lh'}; 

for h = 1:length(hemis)
    hemi_data = load(fullfile(map_dir, [hemis{h} '_prfParams_smooth_layers.mat']));
    
    for m = 1:length(maps)
        % get data vector and filename
        data = hemi_data.allData.(maps{m}); 
        
        % adjust lh.phase map color values for freesurfer
        if strcmp(hemis{h},'lh') && strcmp(maps{m},'phase') 
            % save an unedited version/original
            outfile = fullfile(setup.fsDir, setup.fsSession,'surf', [hemis{h} '.' maps{m} '.mgz']);
            toon_savemgz(data, outfile, fullfile(setup.fsDir, setup.fsSession));

            % save edited file just for visualization            
            dataViz = mod(data + pi, 2*pi); % add pi then modulo 2pi
            outfileViz = fullfile(setup.fsDir, setup.fsSession,'surf', [hemis{h} '.' maps{m} '_Viz.mgz']);
            toon_savemgz(dataViz, outfileViz, fullfile(setup.fsDir, setup.fsSession));
        end
                
        % save data in the subject's surf folder using toon_savemgz
        outfile = fullfile(setup.fsDir, setup.fsSession,'surf', [hemis{h} '.' maps{m} '.mgz']);
        toon_savemgz(data, outfile, fullfile(setup.fsDir, setup.fsSession));    
    end
end

%% 3. Create variance explained masks
% Use Freesurfer commands to create a binarized mask as a label file based 
% on the varexp maps so we can adjust how much data/noise we see in our 
% maps in FreeSurfer

ve_thresh = [0.1, 0.2];

toon_createVarExpMasks(setup.fsSession, hemis, ve_thresh, setup.fsDir)

%% 4. (OPTIONAL) Create flatmaps
% See "How to create a flat map" on the Shared Drive for detailed 
% instructions. Note that you have to use freeview rather than tksurfer if
% it's a newer version of FreeSurfer
%
% https://docs.google.com/document/d/15HSuD-GrapxvqLb2_nJJ0osy2rFlR79_7YbN-ZLolf4/edit?usp=sharing

%% 5. Create partially inflated views in FreeSurfer
% Right now, we are only using 5 iterations, but we can add more as needed
iterations = [5]

toon_partialInflate(setup.fsDir, setup.fsSession, hemis, iterations)

%% 6. Draw ROIs in FreeView
% See tutorial for how to actually draw the ROIs - this will load
% everything you need.
    
% Set map and surface parameters
hemi = 'both'; % rh, lh, both
map = 'place';
surface = 'inflated'; % pial, inflated, semiinflated_n
varexp = 20;
% EVC = {'V1', 'V2d', 'V2v', 'V3d', 'V3v'};
% ROIs = {EVC{:}, 'hV4', 'VO1', 'VO2'};
ROIs = {'pFus_faces', 'mFus_faces', 'mOTS_words', 'pOTS_words', 'CoS_places', 'OTS_bodies',...
    'IOG_faces','ITG_limbs', 'LOS_limbs','IPS_places','MOG_places',...
    'pSTS_faces', 'MTG_limbs'};
%ROIs = {};

%drawRetROIs_freeview_adults(fullfile(setup.fsDir, setup.fsSession), hemi, surface, varexp, ROIs) 
drawRetROIsrhlh_freeview(setup.fsDir, setup.fsSession, hemi, surface, map, varexp, ROIs)
%% NEXT STEP: ROI analysis...
toonCat_step3_ROIanalysis_FS2mrVista
