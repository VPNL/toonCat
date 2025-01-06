function toonCat_calcAveragedCoverage(sessions,hemis,group,exptDir,exptName,atlas,ROIs)
%
% This script will loop through subject retinotopy data and
% will then create averaged coverage maps and extract the data into a file
% for df creation
%
%   sessions: list of subs/sessions
%   hemis: lh and/or rh, array
%   group: name of age group as a string
%   exptDir: path to the experiment directory
%   exptName: expt name and version, used for file name
%   atlas: ROI atlas (toon, wang, cat)
%   ROIs: array of ROI names to include in the df
%
% Adapted from JG 05/2016
% DF 07/2018
% DF 10/2019
% Adapted -> function 8/2023 by JKY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Setup
% Directories
sessionDir = [exptDir 'data'];
dataDir = [exptDir 'results/jewelia'];
figDir = [exptDir 'results/jewelia'];

% Parameters
ve_cutoff = .20;
fieldRange = 20;
fieldRange2plot = 20;
norm = 0;
thresh = 10; %just to pull in files
sigThresh = 0.21; % not sure what this exactly is JKY 08/2023
eThresh = [0, fieldRange];
voxThresh = 10; % minimum number of voxels per ROI
retROISuffix = ['_' atlas '.mat'];


% mrVista Parameters
dt =  'Averages'; scan=1; % set data type and scan
prfModel =  'retModel-cssFit-fFit.mat'; % set pRF model
cothresh=0.2; % set cothresh (variance explained) for thresholding pRF model

%% Loop through hemis and calc centers
for h = 1:length(hemis)
    %% Calculate map variables (center, size, eccentricity, variance, sigma)

    maps={};

    for r = 1:length(ROIs)
        maps = horzcat(maps,{[hemis{h} '.' ROIs{r} retROISuffix]});
    end
   
    clear info subj
    
    %% Set up the pRF sets format

    % 1. info struct
    info.subjs = sessions;
    info.expt = 'toon';
    info.minR2 = ve_cutoff*100;
    info.ROIs = maps;
    info.hemis = hemis;
    % not sure if these are necc...
    info.task = '';
    info.whichStim = 'sweep';
    info.whichModel ='kayCSS';
    info.setNotes = '';
    info.fitSuffix = ''; 

    for i = 1:length(sessions)

       cd(fullfile(sessionDir,sessions{i}))

       % Initialize Toon Session w/ROIs
       vw=toon_initRM(prfModel, {}, cothresh, dt, scan);

       for m = 1:length(maps) % if sub has map, put pRF_cov into data, otherwise fill with NaNs
            clear RFcov coIndices figHandleC all_models weight data size weighted_sum_x weighted_sum_y total_weight;

           if exist(fullfile(sessionDir, sessions{i}, '3DAnatomy', 'ROIs', maps{m})) || exist(fullfile(sessionDir, sessions{i}, '3Danatomy', 'ROIs', maps{m}))
                vw = loadROI(vw,maps{m});
                %vw=viewSet(vw,'selectedroi',m);

                % Set coverage parameters
                method='max'; %method: of computing coverage. I usually use 'sum' or 'max'
                cothresh=0.2; %cothresh:        threshold by variance explained in model
                nboot=50;    %  number of bootstraps; default is 50
                prf_size=1; %     0 = plot pRF center; 1 = use pRF size

                [RFcov, coIndices, figHandleC, all_models, weight, data] = toon_rmPlotCoverage(vw,'method',method,'cothresh',cothresh,'nboot',nboot,'prf_size',prf_size, 'fieldrange', fieldRange2plot);% 'weight',weight
                
                weighted_sum_x = 0;
                weighted_sum_y = 0;
                total_weight = 0;

                % threshold by sig like for pRF centers
                if ~isempty(data) %only if there are above threshold voxels
                    for v = 1:length(data.subSigSize)
  
                        if data.subSigSize(v) > sigThresh && data.subEcc(v) <= fieldRange2plot
                            size(v) = data.subSigSize(v);
                        else
                            size(v) = NaN;
                        end
                    end


                    % Calculate the weighted average for centroid
                    fits(m).CoM_x(:,i) = sum(data.subSigSize .* data.subx0) / sum(data.subSigSize);
                    fits(m).CoM_y(:,i) = sum(data.subSigSize .* data.suby0) / sum(data.subSigSize);
                    fits(m).includedvox(:, i) = sum(~isnan(size));
                    
                else
                    fits(m).includedvox(:, i) = 0;
                    fits(m).CoM_x(:, i) = NaN;
                    fits(m).CoM_y(:, i) = NaN;                 
                end
                    
                % fits(m).includedvox(:, i) = sum(coIndices);

                %only included coverage data for ROIs with more voxels than
                %set threshold and ecc (for later threshold)
                if fits(m).includedvox(:, i) >= thresh
                    disp('Computing coverage parameters');

                    fits(m).coverage(:, :, i) = RFcov;         
                    img = RFcov ./ 1;
                    mask = makecircle(length(img));
                    img = img .* mask;

                    [~, center_x, center_y, ~, fwhm,fwhm_upper, fwhm_lower, fwhm_central5, fwhm_central10, fwhm_contra, fwhm_ipsi, fwhm_upperContra, fwhm_lowerContra, fwhm_upperIpsi, fwhm_lowerIpsi] = toon_fitCircularGauss(double(squeeze(img)),hemis{h}, fieldRange2plot);
                   
                    % Scale the FWHM and centers to fit within the field range
                    scaled_center_x = ((center_x - 1) / (128 - 1)) * (fieldRange - (-fieldRange)) + (-fieldRange);
                    scaled_center_y = ((center_y - 1) / (128 - 1)) * (fieldRange - (-fieldRange)) + (-fieldRange);
                    scaled_fwhm = fwhm * (fieldRange - (-fieldRange)) / 128;
                    

                    % Store the scaled FWHM and centers in the fits structure
                    fits(m).fwhm(:, i) = scaled_fwhm;
                    fits(m).center_x(:, i) = scaled_center_x;
                    fits(m).center_y(:, i) = scaled_center_y;
                    fits(m).fwhm_upper(:, i) = fwhm_upper;
                    fits(m).fwhm_lower(:,i) = fwhm_lower;
                    fits(m).fwhm_central5(:,i) = fwhm_central5;
                    fits(m).fwhm_contra(:,i) = fwhm_contra;
                    fits(m).fwhm_central10(:,i) = fwhm_central10;
                    fits(m).fwhm_ipsi(:,i) = fwhm_ipsi;
                    fits(m).fwhm_upperContra(:,i) = fwhm_upperContra;
                    fits(m).fwhm_lowerContra(:,i) = fwhm_lowerContra;
                    fits(m).fwhm_upperIpsi(:,i) = fwhm_upperIpsi;
                    fits(m).fwhm_lowerIpsi(:,i) = fwhm_lowerIpsi;
                    

                    
                                    
                else 
                    disp('No coverage parameters computed');
                    fits(m).coverage(:, :, i) = NaN(128, 128);
                    fits(m).fwhm(:, i) = NaN;
                    fits(m).fwhm(:, i) = NaN; 
                    fits(m).center_x(:, i) = NaN;
                    fits(m).center_y(:, i) = NaN;
                    fits(m).fwhm_upper(:, i) = NaN;
                    fits(m).fwhm_lower(:,i) = NaN;
                    fits(m).fwhm_central5(:,i) = NaN;
                    fits(m).fwhm_contra(:,i) = NaN;
                    fits(m).fwhm_central10(:,i) = NaN;
                    fits(m).fwhm_ipsi(:,i) = NaN;
                    fits(m).fwhm_upperContra(:,i) = NaN;
                    fits(m).fwhm_lowerContra(:,i) = NaN;
                    fits(m).fwhm_upperIpsi(:,i) = NaN;
                    fits(m).fwhm_lowerIpsi(:,i) = NaN;
                    % fits(m).CoM_x(:, i) = NaN;
                    % fits(m).CoM_y(:, i) = NaN;
                    % fits(m).CoM(:, i) = NaN;  
                end

                fits(m).totalvox(:, i) = numel(coIndices);
                fits(m).ROIname = maps{m};
                fits(m).proportion20(:, i) = sum(coIndices)/numel(coIndices);

           else
                disp('No coverage parameters computed');
                fits(m).coverage(:, :, i) = NaN(128, 128);
                fits(m).includedvox(:, i) = 0;
                fits(m).totalvox(:, i) = 0;
                fits(m).proportion20(:, i) = NaN;
                fits(m).fwhm(:, i) = NaN; 
                fits(m).center_x(:, i) = NaN;
                fits(m).center_y(:, i) = NaN;
                fits(m).CoM_x(:, i) = NaN;
                fits(m).CoM_y(:, i) = NaN;
                fits(m).fwhm_upper(:, i) = NaN;
                fits(m).fwhm_lower(:,i) = NaN;
                fits(m).fwhm_central5(:,i) = NaN;
                fits(m).fwhm_contra(:,i) = NaN;
                fits(m).fwhm_central10(:,i) = NaN;
                fits(m).fwhm_ipsi(:,i) = NaN;
                fits(m).fwhm_upperContra(:,i) = NaN;
                fits(m).fwhm_lowerContra(:,i) = NaN;
                fits(m).fwhm_upperIpsi(:,i) = NaN;
                fits(m).fwhm_lowerIpsi(:,i) = NaN;
            end
        end

        mrvCleanWorkspace;
        close all
    end

    % Save the coverage info 
    % FYP presentation used toonOnly_scaledImg as exptName
    saveFile = fullfile(dataDir, [hemis{h} '.coverage_data_ve', num2str(ve_cutoff*100) '_' num2str(fieldRange) '_voxthresh' num2str(thresh) '_' exptName '_' group '_' atlas 'ROIs.mat']);
    save(saveFile, 'fits');
end