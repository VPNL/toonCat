function toon_2gray_adults(baseDir, session)
% toon_2gray(baseDir, expt, session);
% 
% Step 3 of the workflow for analyzing toonotopy
% Transforms the time series from the inplane to volume anatomy and
% averages the time series
%
% Default Input values
% baseDir       '/biac2/kgs/projects/Kids_AcrossYears/FMRI/Toonotopy/data'
% session        session name, e.g. 'CR24'
%
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
    error('Must define session');
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

%% Load initialized session
load mrInit_params.mat
load mrSESSION.mat

% Open hidden inplane
hi = initHiddenInplane('MotionComp_RefScan1', 1);

%% Install segmentation
% Guess class file path
pattern = fullfile(pwd, '3DAnatomy', '*class*nii*');
w = dir(pattern);
if ~isempty(w),  
    defaultClass = fullfile(pwd, '3DAnatomy', w(1).name);
end
if exist(defaultClass)
    installSegmentation([],[],defaultClass, 3); 
else %open GUI prompt for file name
    installSegmentation([],[],[],3); 
end

%% Transform tseries
% Now we can open a gray view
hg = initHiddenGray('MotionComp_RefScan1', 1);

% Xform time series from inplane to gray using trilinear interpolation
hg = ip2volTSeries(hi,hg,0,'linear');

%% Average tseries 
% in toonotopy we run the same experiment several times (typically 4)
% and average the data across runs to improve SNR
% averaging improves SNR by ~sqrt(runCount)

% get number of runs
[tmp runCount]=size(dataTYPES(1).scanParams);

% average all runs
% generates an Averages dataType
hg = averageTSeries(hg, [1:runCount]);%[1:runCount]

% check that tSeries1 has been created as well as tSeries
% (if not, create) - weird workaround for mrVista
tSeriesStem = fullfile('Gray','Averages','TSeries','Scan1');
tSeries1Path = fullfile(tSeriesStem,'tSeries1.mat');
tSeriesPath = fullfile(tSeriesStem,'tSeries.mat');
if ~exist(tSeries1Path)
    load(tSeriesPath);
    save(tSeries1Path, 'tSeries');
end

% save Session with the new dataTYPE
saveSession;
