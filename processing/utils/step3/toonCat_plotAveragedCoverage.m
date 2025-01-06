function toonCat_plotAveragedCoverage(sessions,hemis,group,exptDir,exptName,atlas,ROIs)
%
% This script will loop through subject retinotopy data and
% will then plot averaged coverage maps
%
%   sessions: list of sessions/subs
%   hemi: lh and/or rh, array
%   group: name of age group as a string
%   exptDir: path to the experiment directory
%   exptName: expt name and version, used for file name
%   atlas: ROI atlas (toon, wang, cat)
%   ROIs: array of ROI names to include in the df
%
% Adapted from JG 05/2016 
% DF 07/2018
% DF 10/2019 toon_plotAveragedCoverage.m
% Adapted by JKY 09/2023
% JKY 11/2023
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sessionDir = [exptDir 'data'];
dataDir = [exptDir 'results/jewelia'];
figDir = [exptDir 'results/jewelia'];
savePath = [exptDir 'results/jewelia'];

% params
ve_cutoff = .20;
fieldRange = 20;
fieldRange2plot = 20;
norm = 0;
thresh = 10; %just to pull in files
retROISuffix = ['_' atlas];


%% Loop through hemis and plot coverage
for h = 1:length(hemis)

    %% Let's load previously saved coverage
    dataFile = fullfile(savePath, [hemis{h} '.coverage_data_ve', num2str(ve_cutoff*100) '_' num2str(fieldRange) '_voxthresh' num2str(thresh) '_' exptName '_' group '_' atlas 'ROIs.mat']);
    load(dataFile);

    avg_centers = fullfile(dataDir,['average_prf_centers_' num2str(fieldRange) '_ve' num2str(ve_cutoff*100) '_plotRange' num2str(fieldRange2plot) '_' exptName '_' group '_' atlas 'ROIs.mat']);
    load(avg_centers)


    for r = length(ROIs):-1:1
            % Fit a circular gaussian and alculate the FWHM for the coverage map
            currentCoverage = double(squeeze(nanmean(fits(r).coverage,3))); % worked with kids but not adults?
            
            if any(isnan(currentCoverage(:)))
                disp(['Skipping ROI ' num2str(r) ' due to NaN values in currentCoverage.']);
                 % Add any other actions or logging you need when skipping an ROI

            else
                % Calculate the center of mass (COM)
                % comX = nanmean(x_val(h,:,r));
                % comY = nanmean(y_val(h,:,r));
    
                % Create new figure for the coverage plot
                f = figure('Position', [100, 100, 600, 600], 'color', 'w');
                
                
                % Plot coverage map
                toon_createCoveragePlot_averaged(currentCoverage, fits(r), ROIs{r}, hemis{h},fieldRange, norm, num2str(sum(fits(r).includedvox >= thresh)));
                %toon_createCoveragePlot_averaged(currentCoverage, ROIs{r}, fieldRange, norm, num2str(sum(~isnan(x_val(h,:,r)))));
    
             
                hold on;
    
                % Plot additional information
                %scatter(comX, comY, 50, 'w', '+'); % Center of mass
                %plot(center_x, center_y, 'w+', 'MarkerSize', 8);  % Plot the center as a blue circle
                colorbar off;
                
                % Save the figure as a PNG
                saveFigFile = fullfile(figDir, 'coverage', group, [hemis{h} '.averageCoverage_' ROIs{r} '_ve' num2str(ve_cutoff*100) '_' num2str(fieldRange) '_voxthresh' num2str(thresh) '_' exptName '_' group '_' atlas 'ROIs_centerCoords.png']);
                saveas(f, saveFigFile, 'png');
                
                close(f);  % Close the figure

        end
    end
end
