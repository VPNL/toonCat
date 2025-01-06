function toon_motionCorrect_adults_exclude(baseDir, session, excluded)
% toon_motionCorrect(baseDir, expt, session, motion_cutoff);
% 
% 
% Runs within and between scan motion correction for Toonotopy experiment
%
% Within scan motion correction relative to the 8th frame of each scan
% params.motionCompRefFrame = 8; % reference TR for motion correction
% Between scan motion correction relative to the first scan in the session
% baseScan = 1;
%
%
% Default Input values
% baseDir       '/biac2/kgs/projects/Kids_AcrossYears/FMRI/Toonotopy/data'
% session        session name, e.g. 'CR24'
% DF 2020 (adapted from code by AS & SP for fLoc)
% JC 2023 (edit for folder structure of adults)

%% Default inputs
if notDefined('baseDir')
    if isunix
        baseDir = fullfile('/oak/stanford/groups/kalanit/biac2/kgs/projects/Kids_AcrossYears/FMRI/Toonotopy/data');
    else
        fprintf(1,'Error, you need to define a base directory \n');
        return
    end
end
if notDefined('session')
    error('must define session')
end
if notDefined('motion_cutoff')
    motion_cutoff = 2; % how many voxels of motion to allow
end

sessionNos = [1:4];
if ~notDefined('excluded')
    sessionNos(excluded) = [];
end

%% Checks
% Check and validate inputs and path to vistasoft
if isempty(which('mrVista'))
    vista_path = 'https://github.com/vistalab/vistasoft';
    error(['Add vistasoft to your matlab path: ', vista_path]);
end

% standardize and validate session argument
sessionDir = fullfile(baseDir, session);

if ~isfolder(sessionDir)
    error(['Session ', session, ' not found in ', baseDir])
    return;
end

cd(sessionDir);
fns = dir(sessionDir);
fns = {fns.name};
lid = fopen('preprocess_log.txt', 'a+');
fprintf(lid, 'Starting motion analysis for session %s. \n\n', session);

%% Load initialized session
load mrInit_params.mat
load mrSESSION.mat

% Open hidden inplane
hi = initHiddenInplane('Original', 1);

% Update params
params.motionCompRefFrame = 8; % reference TR for motion correction
params.motionCompSmoothFrames = 3; % smoothing window for motion correction

% get number of runs
[tmp runCount]=size(dataTYPES(1).scanParams);
%runCount = 3 % for ED07
% do within-scan motion compensation (unless its already been done)
fprintf(lid, 'Starting within-scan motion compensation... \n');
fprintf('Starting within-scan motion compensation... \n');
setpref('VISTA', 'verbose', false); % suppress wait bar
if ~exist(fullfile(sessionDir, 'Images', 'Within_Scan_Motion_Est.fig'), 'file')
    hi = motionCompSelScan(hi, 'MotionComp', sessionNos, ... 
        params.motionCompRefFrame, params.motionCompSmoothFrames);
    saveSession; % close all;
end

fprintf(lid, 'Within-scan motion compensation complete. \n\n');
fprintf('Within-scan motion compensation complete. \n\n');

% do between-scan motion compensation (unless its already been done)
fprintf(lid, 'Starting between-scan motion compensation... \n');
fprintf('Starting between-scan motion compensation... \n');
if ~exist(fullfile(sessionDir, 'Between_Scan_Motion.txt'), 'file')
    hi = initHiddenInplane('MotionComp', 1);
    baseScan = 1;
    targetScans = sessionNos;
    [hi, M] = betweenScanMotComp(hi, 'MotionComp_RefScan1', baseScan, targetScans);
    fname = fullfile('Inplane', 'MotionComp_RefScan1', 'ScanMotionCompParams');
    save(fname, 'M', 'baseScan', 'targetScans');
    hi = selectDataType(hi, 'MotionComp_RefScan1');
    saveSession;
    close all;
end

fprintf(lid, 'Between-scan motion compensation complete. \n\n');
fprintf('Between-scan motion compensation complete. \n\n');

fprintf(lid, 'preProcessing for %s is complete! \n', session);
fprintf('preProcessing for %s is complete! \n', session);
fclose(lid);
err = 0;
