function toon_init(baseDir, expt, session, canonXflag, clip, runBase)
% 
% toon_init(baseDir, expt, session, canonXflag,clip, runBase)
%
% Step 1 of the workflow for analyzing toonotopy
% Initializes the data for mrVista
%
% Default Input values
% baseDir  '/biac2/kgs/projects/'
% expt     '/psych224/data/OS12/'
% session   session name, e.g. 'OS12_190725_20947_time_06_1'
% canonXflag 0; flag to apply cannonical transformation to niftis
% clip      6; number of frames/TRs to clip from beginning of experiment;
% keep      96; number of frames/TRs to keep 
% runBase  'run' ; nifti file tag that designates the toon data
%
% DF 2020 (adapted from code by AS & SP for fLoc)

%% Inputs/Default params
if notDefined('baseDir')
    if isunix
        baseDir = fullfile('/sni-storage', 'kalanit', 'biac2', 'kgs', 'projects');
    else
        fprintf(1,'Error. You need to define base directory \n');
        return
    end
end
if notDefined('expt')
    expt = '/psych224/data/OS12/';
end
if notDefined('session')    
    session = 'OS12_190725_20947_time_06_1';
end
if notDefined('canonXflag')
    canonXFlag = 0;
end
if notDefined('clip')
    clip = 6;
end
if notDefined('keep')
    keep = 96;
end
if notDefined('runBase')
    runBase = 'run'; % or 'run';
end

%% Checks
% Check and validate inputs and path to vistasoft

if isempty(which('mrVista'))
    vista_path = 'https://github.com/vistalab/vistasoft';
    error(['Add vistasoft to your matlab path: ', vista_path]);
end

% standardize and validate session argument
exptDir = fullfile(baseDir, expt);

dd = dir(exptDir);
allSessions = {dd([dd.isdir]).name};
if length(allSessions) < 3
    error(['No valid session data directories found in ', exptDir]);
    return;
else
    allSessions = allSessions(3:end);
end
if sum(strcmp(session, allSessions)) ~= 1
    error(['Session ', session, ' not found in ', exptDir]);
    return;
end

% look for niftis and create preproc log
sessionDir = fullfile(exptDir, session);
cd(sessionDir);
fns = dir(sessionDir);
fns = {fns.name};
lid = fopen('preprocess_log.txt', 'w+');
fprintf(lid, 'Starting preprocessing analysis for session %s. \n\n', session);
fprintf('Starting preprocessing for session %s. \n\n', session);

%% Optional transformation
% apply cannonical transformation to nifti files and resave
if canonXFlag transformerDir(sessionDir); end

%% Load niftis and get params
runCount = 0;
for n = 1:length(fns)
    if containsTxt(fns{n}, runBase) && ~strcmp(fns{n}(1), '.')
        runCount = runCount + 1;
        niiFiles{runCount} = fns{n};
    end
end
nii = niftiRead(niiFiles{1});
nSlices = size(nii.data, 3); % inplane x slices
tr = nii.pixdim(4); % how many TRs, time component
clear nii;

% paths to niftis for each run
niiFiles = natsort(niiFiles);
niiFiles = cellfun(@(X) fullfile(sessionDir, X), niiFiles, 'uni', false);

if length(clip) == 1
    clip = repmat(clip, 1, runCount);
elseif length(clip) ~= length(session)
    fprintf(lid, 'Error -- Length of clip argument is inconsistent with number of runs. \nExited analysis.');
    fprintf('Error -- Length of clip argument is inconsistent with number of runs. \nExited analysis.');
    fclose(lid);
    return;
end
keepFrames = [clip(:), repmat(keep, length(clip), 1)];

%% Initialize mrVista session

% setup analysis parameters 
params = mrInitDefaultParams;
params.doAnalParams = 1;
params.doSkipFrames = 1;
params.doPreprocessing = 0;
params.functionals = niiFiles; % paths to runs of fMRI data
params.subject = session; % name of session directory
params.keepFrames = keepFrames; % TRs to model (after clipping)
params.scanGroups = {1:runCount}; % group all runs of localizer
params.motionComp = 0; % disable motion correction for now

% look for T1 volume and leave blank if none exists
if exist(fullfile(sessionDir, '3DAnatomy', 't1.nii.gz'), 'file') == 2
    params.vAnatomy = fullfile(sessionDir, '3DAnatomy', 't1.nii.gz');
end

% look for inplane volume
dd = dir('*inplane*');
if isempty(dd) 
    dd = dir('*Inplane*');
end
inplane = dd.name;
if isempty(inplane)
    fprintf(lid, 'Warning -- Inplane scan not found. Continued analysis. \n');
    fprintf('Warning -- Inplane scan not found. Continued analysis. \n');
else
    params.inplane = fullfile(sessionDir, inplane);
end

% inititalize vistasoft session and open hidden inplane view
fprintf(lid, 'Initializing vistasoft session directory in: \n%s \n\n', sessionDir);
fprintf('Initializing vistasoft session directory in: \n%s \n\n', sessionDir);
if ~exist(fullfile(sessionDir, 'Inplane'), 'dir')
    mrInit(params);
end
