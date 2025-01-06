function toonCat_loopSigmavsEcc(sessions,group,exptDir,exptName,atlas,roiList,resultsDir,vethresh, eccthresh, sigthresh, voxthresh)
%
% This script will plot the ecc vs. pRF size for a list of ROIs and loop
% through a list of subjects, saving out each subject's figures into a
% figure directory. It will also save out the regression information for
% each ROI that a subject (slope, intercept, age, variance, etc). This
% script can't be run for the purposes of figure reproduction, but was
% included as an example of how to loop mrVista code for other labs to use.
%
% JG 05/2016 toon_loopSigmaVsEcc
% JKY 10/2023
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Directories
sessionDir = [exptDir 'data'];
dataDir = [exptDir resultsDir];

% Set threshold variables here:
vethresh =  0.20;
voxthresh = 10;
eccthresh = [0 20]; % leave out very close to fovea due to presence of space ship, and we want to minimize edging effects so we'll stop at 6.5
sigthresh = [0.21 20];

% The structure in which we will store all subject data to save out:
lineData = {};

% We'll spit out problem subjects at the end if someone is missing
% something
errors = {};


for s = 1:length(sessions)

   cd(fullfile(sessionDir,sessions{s}))
   load mrSESSION.mat;

    % Initialize a hidden gray view and the retinotopy model you've run
    view = initHiddenGray('Averages',1);
    rmPath = fullfile('Gray','Averages','retModel-cssFit-fFit.mat');
    view = rmSelect(view,1,rmPath);

   fprintf('\n\n\nProcessing %s\n\n\n',sessions{s})

   % The loop below will only include an ROI if it both exists and is
   % greater than 8 voxels (which is ~1 inplane functional voxel size).
   for r = 1:length(roiList)
       if exist(fullfile(sessionDir,sessions{s},'3DAnatomy','ROIs',roiList{r}), 'file')
           load(fullfile(sessionDir,sessions{s},'3DAnatomy','ROIs',roiList{r}));
       end
   end
   
   
   if ~isempty(roiList)
       
       view = loadROI(view,roiList);
      
       list = 1:length(viewGet(view, 'ROIs'));
       
       % Run regression and store data into a structure
       data = s_rmPlotMultiEccSigma(view, list, vethresh, eccthresh, sigthresh, voxthresh);
   
       myTitle = title(sessions{s},'fontsize',16); set(myTitle,'interpreter','none');
       print('-r300','-dpng',fullfile(dataDir,'images'))
       
       
       lineData{s} = data;
   else
       % Put a place holder if the subject doesn't have the ROI
       lineData{s} = '';
   end
   
   
   mrvCleanWorkspace; close all;

end

saveFile = ['toonCat_EccVsSigma_lineData_allHemi_' exptName '_' group, '_' atlas 'ROIs.mat'];
save(fullfile(dataDir,saveFile),'lineData')