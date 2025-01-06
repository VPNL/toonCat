
%% toonCat_step4_convert_catMaps.m %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 4 in toonotopy-category selectivity development project. After
% running step 1 -step 3, we run this script to convert the fLOC contrast
% maps into the corresponding toon anatomy of our retinotopy subjects.
%
% REQUIRED: analyzed fLOC data
%
% In this script:
%
% 1. Setup
% 2. Install FS segmentation
% 3. Alignment
% 4. Contrast Maps -> Gray
% 5. Contrast Maps -> FS
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
addpath(genpath('/share/kalanit/biac2/kgs/projects/toonAtlas/code')) % Dawn's code
addpath(genpath('/share/kalanit/software/vistasoft/')) 
addpath(genpath(fullfile(oak_prefix, 'kalanit/biac2/kgs/projects/Kids_AcrossYears/FMRI/Toonotopy/code')))
addpath(genpath(fullfile(share_prefix, 'biac2/kgs/projects/toonAtlas/code/knkutils/io')))

%% 1. Toon Setup
% Use setSessions_kidsToon.m to setup the subject, session, and FreeSurfer
% directories
clear all
share_prefix = '/share/kalanit';
oak_prefix = '/oak/stanford/groups';
% setSessions information
subID = 'JG24';
[sessions, fs_sessions] = setSessions_kidsToon(subID, 1);

setup.vistaDir = fullfile(oak_prefix, 'kalanit/biac2/kgs/projects/Kids_AcrossYears/FMRI/Toonotopy/data');
setup.fsDir = fullfile(oak_prefix, 'kalanit/biac2/kgs/anatomy/freesurferRecon/Kids_AcrossYears');
setup.subID = subID;
setup.fsSession = fs_sessions;
setup.vistaSession = sessions;

% Set FreeSurfer Directory
k_AY_base_dir= setup.fsDir;
setenv('SUBJECTS_DIR', k_AY_base_dir);

%% 1. Cat Setup
% NOTE: 3DAnatomy folder should be the same across both the toonotopy and
% the category experiments; we want to use the same session to analyze the
% ROIs

catSession = 'JG24_170109_time_04_1';
toonCat_path = fullfile(oak_prefix,'kalanit/biac2/kgs/projects/Kids_AcrossYears/FMRI/Localizer/data_toonCat');
session_path = fullfile(toonCat_path, catSession);

%% 1. Setup: Load session parameters
cd(session_path)

% Load initialized session
load mrInit_params.mat
load mrSESSION.mat

    
% Set vAnatomy
vANATOMYPATH = fullfile(session_path, '3DAnatomy', 't1.nii.gz');
setVAnatomyPath = fullfile(session_path, '3DAnatomy', 't1.nii.gz');
saveSession;

%% 2.Align inplane anatomy to volume anatomy
% Open this script s_alignInplaneToAnatomical.m and run section by section.
% Note the optional sections, which you do not have to run.

s_alignInplaneToAnatomical

%% 3.Install FreeSurfer Segmentation
% Taken from toon_2gray!
toon_installSegmentation(session_path);
%% 4.Xform inplane to gray
% transforms all of the contrasts to the gray

cd(session_path);

hg = initHiddenGray('GLMs', 1);
hi = initHiddenInplane('GLMs', 1);
ip2volAllParMaps(hi, hg,'linear');

saveSession;
%% 5.Import contrast maps into FreeSurfer
% go through all the generated constrast maps for Gray and convert them
% into FreeSurfer compatible maps in 3DAnatomy/surf
% this takes a while because it's converting all the maps at once!
cd(session_path);
% % get an array of all the .mat contrast filenames
% session_gray_dir = fullfile(session_path, 'Gray', 'GLMs');
% gray_GLMs = dir(fullfile(session_gray_dir, '*.*'));
% gray_contrasts_names = {gray_GLMs.name};
% gray_contrasts_names = gray_contrasts_names(5:length(gray_contrasts_names)); %skips the first 4 entries of the .mat file arrays

% If contrast doesn't exist, run this:
% toonCat_makeContrastMap

% get an array of all the .mat contrast filenames
session_gray_dir = fullfile(session_path, 'Gray', 'GLMs');
gray_contrasts_names={'faceadultfacechild_vs_all.mat', 'Word_vs_all_except_Number.mat','BodyLimb_vs_all.mat', 'PlaceHouse_vs_all.mat', 'CarGuitar_vs_all.mat'};
%gray_contrasts_names={'Bodies_vs_all.mat', 'Characters_vs_all.mat','Faces_vs_all.mat', 'Objects_vs_all.mat', 'Places_vs_all.mat'};

% convert each contrast map into a Freesurfer compatible map
for i = 1:length(gray_contrasts_names)
    curr_contrast_name_cell = gray_contrasts_names(i);
    curr_contrast_name = char(curr_contrast_name_cell{1});
    map_path = fullfile(session_gray_dir, curr_contrast_name);
    
    toonCat_mrvGray2fsSurf_parameterMaps(session_path, map_path, fullfile(setup.fsDir, setup.fsSession), setup.fsSession)
end

disp(['Successfully converted ' num2str(length(gray_contrasts_names)) ' mrVista contrast maps into Freesurfer compatible maps! Saved to ' session_gray_dir '.'])
fprintf('Successfully converted %d mrVista contrast maps into Freesurfer compatible maps.\n\n', length(gray_contrasts_names));
