%% toonCat_step5_drawCatROIs_FS.m %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 5 in toonotopy-category selectivity development project. After
% running step 1 -step 4, we run this script to draw ROIs from the category
% maps.
%
%
%
% JKY Nov 2023
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all;
clear all;

% 0.Pathing
share_prefix = '/share/kalanit';
oak_prefix = '/oak/stanford/groups';
% share_prefix = '/Volumes';
% oak_prefix = '/Volumes';

% 0.Toolboxes
addpath(genpath(fullfile(oak_prefix, 'kalanit/biac2/kgs/projects/Kids_AcrossYears/FMRI/Toonotopy/code')))
addpath(genpath(fullfile(share_prefix, 'biac2/kgs/projects/toonAtlas/code/knkutils/io')))

%% 1. Toon Setup
% Use setSessions_kidsToon.m to setup the subject, session, and FreeSurfer
% directories

% setSessions information
subID = 'CS11';
[sessions, fs_sessions] = setSessions_kidsToon(subID, 1);

setup.vistaDir = fullfile(oak_prefix, 'kalanit/biac2/kgs/projects/Kids_AcrossYears/FMRI/Toonotopy/data');
setup.fsDir = fullfile(oak_prefix, 'kalanit/biac2/kgs/anatomy/freesurferRecon/Kids_AcrossYears');
setup.subID = subID;
setup.fsSession = fs_sessions;
setup.vistaSession = sessions;

% Set FreeSurfer Directory
k_AY_base_dir = setup.fsDir;
setenv('SUBJECTS_DIR', k_AY_base_dir);

%% 6. Draw ROIs in FreeSurfer
% Set map and surface parameters
hemi = 'both'; % lh, rh, both
surface = 'semiinflated_5'; % pial, inflated, semiinflated_n
map = 'category'; % phase, eccen, size, varexp, category, category5
varexp = 20;
ROIs = {'mOTS_words', 'pOTS_words', 'mFus_faces', 'pFus_faces'};

% ROIs = {'pSTS_faces'};
%ROIs = {'IOG_faces', 'pSTS_faces', 'ITG_limbs', 'LOS_limbs', ...
%    'MTG_limbs', 'IPSl_places', 'IPSm_places', 'MOG_places'};
%viewLatCatROIs_JC(setup.fsDir, setup.fsSession, surface, map, ROIs);
drawRetROIsrhlh_freeview(setup.fsDir, setup.fsSession, hemi, surface, map, varexp, ROIs)

