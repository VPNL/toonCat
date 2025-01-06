function toon_prfRun_adults(baseDir, session, paramPath, imgPath)
% toon_prfRun(baseDir, expt, session);
% 
% Step 4 of the workflow for analyzing toonotopy
% Runs the prf model (CSS)
%
% Default Input values
% baseDir       '/biac2/kgs/projects/Kids_AcrossYears/FMRI/Toonotopy/data'
% session        session name, e.g. 'CR24
% paramPath     'Stimuli/8bars_params.mat';
% imgPath       'Stimuli/8bars_images.mat';
%
% DF 2020 (adapted from code by RL & JG)
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
if notDefined('paramPath')
    paramPath= 'Stimuli/8bars_params.mat';
end
if notDefined('imgPath')
    imgPath= 'Stimuli/8bars_images.mat';
end
%% Setup
close all; clc;

cd(baseDir);

% list of knk scan number, corresponding to session list
list_numKnk = 1;

% dataTYPE name. Can run for mutiple datatypes
list_rmName = {'Averages'};

% prf model. Specify in a cell. Options:
% {'one oval gaussian' | 'onegaussian' | 'css'}
% Note: if we want to specify multiple models, change the naming
% convention. See outFileName
prfModel = {'css'};

% search type.
% 1 = grid search only ("coarse"),
% 2 = minimization search only ("fine"),
% 3 = grid followed by minimization search [default]
wSearch = 3;

% radius of circle retinotopy in visual angle degrees
% 20 for wide field and 7 for normal
p.stimSize = 20;

%% Define things common to all datatypes

% name of params file
p.paramsFile_Knk = paramPath;
% image file
p.imFile_Knk = imgPath;

% params common to all dts
params.stimSize = p.stimSize;
params.fliprotate = [0, 0, 0]; %[L/R flip up/down flip rotate degrees]
params.stimType = 'StimFromScan';
params.stimWidth = 90;
params.stimStart = 0;
params.stimDir = 0;
params.nCycles = 1;
params.nStimOnOff = 0;
params.nUniqueRep = 1;
params.nDCT = 1;
params.hrfType = 'two gammas (SPM style)';
params.hrfParams = {[1.6800, 3, 2.0500], [5.4000, 5.2000, 10.8000, 7.3500, 0.3500]};
params.imfilter = 'binary';
params.jitterFile = 'Stimuli/none';

%% Run the prf model
% directory with ret vista session. move here
cd(fullfile(baseDir, session));

% open the session
vw = initHiddenGray;

% need some global variables later
load mrSESSION;

% ret parameters based on the subject
% scan number with checkers and knk, for clip frame information
p.scanNum_Knk = list_numKnk;

%% loop over the datatypes
for kk = 1:length(list_rmName)

    % set current dataTYPE
    rmName = list_rmName{kk};
    vw = viewSet(vw, 'curdt', rmName);

    % get the dataType struct
    dtstruct = viewGet(vw, 'dtstruct');

    % get the data type number for later
    dataNum = viewGet(vw, 'curdt');

    % Set parameter and image files
    params.paramsFile = p.paramsFile_Knk;
    params.imFile = p.imFile_Knk;
    p.scanNum = p.scanNum_Knk;

    %% getting parameter values for prf model fit ----------------------
    params.nFrames = viewGet(vw, 'nFrames');
    params.framePeriod = viewGet(vw, 'framePeriod');
    tem.totalFrames = mrSESSION.functionals(p.scanNum).totalFrames;
    params.prescanDuration = (tem.totalFrames - params.nFrames) * params.framePeriod;

    % store it
    dataTYPES(dataNum).retinotopyModelParams = params;

    % save it
    saveSession;

    %% Put the rm params into the view structure

    vw = rmLoadParameters(vw);
    % the function rmLoadParameters used to call both rmDefineParameters
    % and rmMakeStimulus. If we do it here so that we can give it arguments
    % outside of the default (eg previously, sigma major and minor would be
    % identical despite having prfModel = {'one oval gaussian'} when
    % specifying it as an argument in vw = rmMain(vw, ...)

    % store params in view struct
    vw = viewSet(vw, 'rmParams', params);

    %% RUN THE PRF!
	
	% name the ret model - whole brain
	outFileName = ['retModel-', prfModel{1}, 'Fit'];
	
	% no nned to load rois, just run it!
	vw = rmMain(vw, [], wSearch, 'model', prfModel, 'matFileName', outFileName);
	
end
