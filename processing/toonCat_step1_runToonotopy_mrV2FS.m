%% toonCat_step1_runToonotopy_mrV2FS.m %%%%%%%%%%%%%%%%%%%%%%%%
% Step 1 in toonotopy-category selectivity development project. This script
% uses mrVista to prepare and run the retinotopy CSS pRF model using a
% FreeSurfer mesh. It converts the output to FreeSurfer for ROI drawing
% (toonCat_step2). Copy into each subject's code folder. Script is designed
% for kid sub folders - see toonCat_step1_runToonotopy_mrV2FS_adults.m for
% adult subs.
%
% REQUIRED: recon FreeSurfer anatomy, mrVista 3D anatomy, toon runs,
% inplane, setSessions_toonCat
%
% In this script:
% 
% 1. Setup
% 2. Convert T1 + T1 ribbon from FS -> mrVista
% 3. Initialize mrVista toonotopy session
% 4. Align inplane to volume
% 5. Motion correct
% 6. Install segmentation, tSeries -> Gray, and average time series
% 7. Install FS mesh
% 8. Run CSS model (Kay et al., 2013)
% 9. Convert parameter maps from mrVista -> FS
% 10. (Optional) Transform Kastner Atlas
%
% DF 2020
% JKY Apr 2023
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all

%% 0. Pathing
% Change path prefixes depending on code access

% Server
share_prefix = '/share/kalanit';
oak_prefix = '/oak/stanford/groups';

% Mounted
% share_prefix = '/Volumes';
% oak_prefix = '/Volumes';

%% 0. Toolboxes
% Toolboxes for mrVista software, toonotopy specific functions (DF 2020),
% and pipeline functions
addpath(genpath(fullfile(share_prefix, 'biac2/kgs/projects/toonAtlas/code'))); 
addpath(genpath(fullfile(share_prefix, 'software/vistasoft/'))); 
addpath(genpath(fullfile(oak_prefix, 'kalanit/biac2/kgs/projects/Kids_AcrossYears/FMRI/Toonotopy/code')));

%% 1. Setup
% Use setSessions_toonCat.m to setup the subject, session, and FreeSurfer
% directories

% setSessions index
subID = 'JG24';
sessID = 1;
[sessions, fs_sessions] = setSessions_toonCat(subID, sessID);

% Create setup structure
setup.vistaDir = fullfile(oak_prefix, 'kalanit/biac2/kgs/projects/Kids_AcrossYears/FMRI/Localizer/data');
setup.fsDir = fullfile(oak_prefix, 'kalanit/biac2/kgs/anatomy/freesurferRecon/Kids_AcrossYears');
setup.subID = subID;
setup.fsSession = fs_sessions;
setup.vistaSession = sessions;
subjid = setup.fsSession;

% Set FreeSurfer Directory
setenv('SUBJECTS_DIR', setup.fsDir);

% Create mrVista directory
vistaDir = fullfile(setup.vistaDir, setup.subID, setup.vistaSession);
if ~exist(vistaDir,'dir')
    fprintf(1,'mkdir %s \n',vistaDir)
    mkdir(vistaDir)
end
cd(vistaDir)

% Create anatomy directory
anatDir = fullfile(setup.vistaDir, setup.subID, setup.vistaSession, '3DAnatomy');
if ~exist(anatDir,'dir')
    fprintf(1,'mkdir %s \n',anatDir)
    mkdir(anatDir)
end

%% 2. Convert T1 and fix class file
% Take T1 (gray/white matter volume) + ribbon (gray matter only) files from
% freesurfer recon and convert to mrVista nifti files. They will be called
% t1.nii.gz and t1_class.nii.gz in the 3DAnatomy folder.

% Get subject's FreeSurfer recon path 
cd(fullfile(setup.fsDir, setup.fsSession))

% Path to T1.mgz file created by FreeSurfer
T1.mgz = sprintf('./mri/T1.mgz');

% Path to t1.nii.gz to be output by conversion
T1.nii = sprintf('./nifti/t1.nii.gz');
if ~exist('/nifti', 'dir')
    mkdir('nifti');
end

% Convert FS recon t1.mgz to nifti format (using nearest neighbor).
% This function cannot overwrite any existing files, so if there is an
% existing file, it will ask the user what to do. 
if exist(T1.nii, 'file')
    prompt = 'This file already exists. Are you sure you want to overwrite it? Press 1 for yes, 2 for no: ';
    x = input(prompt);
    if x == 1
        delete './nifti/t1.nii.gz'
        str = sprintf('mri_convert --resample_type nearest --out_orientation RAS -i %s -o %s', T1.mgz, T1.nii);
        system(str)
    end
else
    str = sprintf('mri_convert --resample_type nearest --out_orientation RAS -i %s -o %s', T1.mgz, T1.nii);
    system(str)
end

% Convert the FS ribbon.mgz to a nifti class file (which is used by mrVista
% to create 3D meshes)
fsRibbonFile  = fullfile('./mri/ribbon.mgz');  % Full path to the ribbon.mgz file, or it can be name of directory in freesurfer subject directory (string). 
outfile       = fullfile('./nifti/t1_class.nii.gz');
fillWithCSF   = true;
alignTo       = T1.nii;
resample_type = [];
if exist(outfile, 'file')
    x = input(prompt);
    if x == 1
        delete './nifti/t1_class.nii.gz'
        fs_ribbon2itk(fsRibbonFile, outfile, fillWithCSF, alignTo, resample_type)
    end
else
    fs_ribbon2itk(fsRibbonFile, outfile, fillWithCSF, alignTo, resample_type)
end

% Copy our T1 and class file over to the mrVista session
copyfile(T1.nii, anatDir)
copyfile(outfile, anatDir)

%% 3. Initialize mrVista toon session
% Load the functional runs and extract parameters. Also, create the
% preprocess.txt log and mrSESSION.mat and mrInit_params.mat files.

% Get filepaths
cd(vistaDir)
baseDir = setup.vistaDir;
paramPath =fullfile('Stimuli','8bars_params.mat');
imgPath = fullfile('Stimuli','8bars_images_flippedLRUD.mat');

% Initialize session if new
%if exist('mrSESSION.mat') ~=2
    toon_init(baseDir, setup.subID , setup.vistaSession)
%end
%% 4. Align inplane anatomy to volume anatomy
% Open this script s_alignInplaneToAnatomical.m and run section by section.
% Note the optional sections, which you do not have to run.

s_alignInplaneToAnatomical

%% 5. Motion correct toon session
% Motion corrects between and within scans. For quality assurance, do not
% include subjects with motion > 2mm/~1 voxel. Creates MotionComp and
% MotionComp_RefScan1 folders.

toon_motionCorrect(baseDir, setup.subID, setup.vistaSession);

%% 6. Install segmentation, transform tSeries to Gray, and average time series
% Transforms motion corrected time series from inplane to the ribbon and
% averages. Output in Averages folder.

toon_2gray(baseDir, setup.subID, setup.vistaSession);

%% 7. Import FreeSurfer mesh into mrVista
% Imports the freesurfer surface into mrVista so that our maps can be
% transformed into freesurfer space later on.

fsSurfPath = fullfile(setup.fsDir, setup.fsSession, 'surf');
vista3DAnatomyPath = fullfile(setup.vistaDir, setup.subID, setup.vistaSession, '3DAnatomy');
toon_surf2msh(fsSurfPath, vista3DAnatomyPath)

% Check session in mrVista (save preferences)
% mrVista 3

% Note: in toon_surf2msh, comment out the meshVisualize if using
% a newer version of Ubuntu. If not, load and inflate mesh to view maps on
% the cortical surface

%% 8. Run CSS pRF model
% Runs the compressive spatial summation model (Kay et al., 2013) with
% parameters set in toon_prfRun. This requires vistasoft to run the actual
% model (rmMain)

toon_prfRun(baseDir, setup.subID, setup.vistaSession, paramPath, imgPath)

%% 9. Convert parameter maps to FreeSurfer surfaces
%  Once the CSS model is done (and you've checked in mrvista that it looks
%  okay) you can convert the maps to freesurfer surface coords for
%  visualization and ROI drawing (step 2).

smooth = 1; %smooth to match previous stages
direct_mrvEccen2fs(fullfile(setup.vistaDir, setup.subID, setup.vistaSession), ...
                   fullfile(setup.fsDir, setup.fsSession), smooth)
%% 10. Transform Kastner atlas from fsaverage space to subject space to use as a reference (optional)
transform_KastnerAtlas;

%% NEXT STEP: ROI drawing...
toonCat_step2_drawToonROIs_FS

