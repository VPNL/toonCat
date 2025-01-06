function toonCat_getVoxelsVE(sessions,hemis,group,exptDir,exptName,atlas,ROIs)
%
% This script will loop through subject retinotopy data and
% extract the total voxels in an ROI and the number of voxels with VE of
% 20% or larger and turn it into a dataframe. These variables are set early
% in Step 3 Setup
%
%   sessions: list of sessions/subs
%   hemis: lh and/or rh, array
%   group: name of age group as a string
%   exptDir: path to the experiment directory
%   exptName: expt name and version, used for file name
%   atlas: ROI atlas (toon, wang, cat)
%   ROIs: array of ROI names to include in the df
%
% JKY 2023
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Setup
% Directories
sessionDir = [exptDir 'data'];
dataDir = [exptDir 'results/jewelia'];

% Parameters
ve_cutoff = 0.2;
fieldRange = 40;
fieldRange2plot = 20;
norm = 0;
thresh = 10; %just to pull in files
sigThresh = 0.21; 
eThresh = [0, fieldRange];
voxThresh = 10; % minimum number of voxels per ROI
retROISuffix = ['_' atlas];

%% Loop through hemis
for h = 1:length(hemis)
    
    %% Calculate VE 20/total voxels

    maps={};
    for r = 1:length(ROIs)
        maps = horzcat(maps,{[hemis{h} '.' ROIs{r} retROISuffix]});
    end

    for i = 1:length(sessions)

        cd(fullfile(sessionDir, sessions{i}))
        load mrSESSION.mat;

        clear dataTYPES mrSESSION vANATOMYPATH;

        % Now load the appropriate datatype
        view = initHiddenGray('Averages', 1);
        rmPath = fullfile('Gray', 'Averages', 'retModel-cssFit-fFit.mat');
        view = rmSelect(view, 1, rmPath);

        for m = 1:length(maps) % if sub has map, put pRF_cov into data, otherwise fill with NaNs
            
            clear totalVox CoVox;
            
            if exist(fullfile(sessionDir, sessions{i}, '3DAnatomy', 'ROIs', [maps{m}, '.mat'])) || exist(fullfile(sessionDir, sessions{i}, '3Danatomy', 'ROIs', [maps{m}, '.mat']))                
                view = loadROI(view,[maps{m}, '.mat']);
                [totalVox, CoVox] = toon_getVoxelsVE(view,'prf_size',1,'fieldRange',fieldRange,'method','maximum profile','nboot',50,'normalizeRange',0,'smoothSigma',1,'cothresh',ve_cutoff,'weight','variance explained','sigmathresh',sigThresh,'eccthresh',eThresh,'addcenters',1,'newfig',0, 'flips', 0, 'css', 1);
                %[pRF_COV, coIndices, figHandle, all_models, weight, data] = rmPlotCoverage_flips(view,'prf_size',1,'fieldRange',fieldRange,'method','maximum profile','nboot',50,'normalizeRange',0,'smoothSigma',1,'cothresh',ve_cutoff,'weight','variance explained','sigmathresh',sigThresh,'eccthresh',eThresh,'addcenters',1,'newfig',0, 'flips', 0, 'css', 1);

                fits(m).allROIVox(:, i) = totalVox;
                fits(m).VE20ROIVox(:, i) = CoVox;
                fits(m).proportion(:, i) = CoVox/totalVox;
                fits(m).ROIname = maps{m};
            else
                fits(m).allROIVox(:, i) = NaN;
                fits(m).VE20ROIVox(:,i) = NaN;
                fits(m).proportion(:, i) = NaN;
            end
        end

        mrvCleanWorkspace;

    end

    %Save the coverage info 
    saveFile = fullfile(dataDir, [hemis{h} '.ProportionVoxels_ve', num2str(ve_cutoff*100) '_' num2str(fieldRange) '_voxthresh' num2str(thresh) '_' exptName '_' group, '_' atlas 'ROIs.mat']);
    save(saveFile, 'fits');
end