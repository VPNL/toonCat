function toonCat_getFWHMCenters_df(sessions,hems,group,exptDir,exptName,atlas,ROIs,resultsDir,ve_cutoff, fieldRange,fieldRange2plot,norm,thresh)

% This script calculates the full-width half max for each of the subjects,
% hemispheres, and ROIs and stores it in a table that can be exported to R
% Markdown for statistical analysis. It also has been edited to include the
% pRF center of mass (x and y coordinates calculated with the FWHM), and
% the included and total voxels driven by toonotopy.
%
%   sessions: list of sessions/subs
%   hemis: lh and/or rh, array
%   group: name of age group as a string
%   exptDir: path to the experiment directory
%   exptName: expt name and version, used for file name
%   atlas: ROI atlas (toon, wang, cat)
%   ROIs: array of ROI names to include in the df
%   resultsDir: results/save out folder in exptDir
%
% JKY 2023
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Directories
dataDir = [exptDir resultsDir];

% Initialize cell arrays to store data
sub = {};
hemi = {};
ROI = {};
FWHMs = [];
FWHM_radius = [];
CenterXs = [];
CenterYs = [];
size = [];

for h = 1:length(hems)

    % Load the saved data file
    if hems{h} == 'rh'
        load(fullfile(dataDir, ['rh.pRFset_' num2str(fieldRange)  '_ve' num2str(ve_cutoff*100) '_voxthresh' num2str(thresh) '_plotRange' num2str(fieldRange2plot) '_' exptName '_' group '_' atlas 'ROIs.mat']));
    else
        load(fullfile(dataDir, ['lh.pRFset_' num2str(fieldRange)  '_ve' num2str(ve_cutoff*100) '_voxthresh' num2str(thresh) '_plotRange' num2str(fieldRange2plot) '_' exptName '_' group '_' atlas 'ROIs.mat']));
    end

    % Loop through subjects
    for i = 1:length(sessions)
        % Loop through ROIs
        for m = 1:length(ROIs)
            if length([subj(i).roi(m).fits(1).vox(:).eccen]) >= thresh
                % Get pRF centers for this ROI and subject
                centerX_NaN = [subj(i).roi(m).fits(1).vox.X];
                centerX = centerX_NaN(~isnan(centerX_NaN));
                CoM_x = mean(centerX);
    
                centerY_NaN = [subj(i).roi(m).fits(1).vox.Y];
                centerY = centerY_NaN(~isnan(centerY_NaN));
                CoM_y = mean(centerY);
    
                % Get FWHM of the pRF centers
                % Calculate radial distances from the center
                radial_distance = sqrt((centerX - CoM_x).^2 + (centerY - CoM_y).^2);
                
                % Standard deviation of radial distances
                std_deviation_radius = std(radial_distance);
                
                % FWHM as twice the standard deviation
                fwhm_radius = 2 * std_deviation_radius;
                FWHM = fwhm_radius * 2;
    
                % size of pRF centers
                pRFSize_NaN = [subj(i).roi(m).fits(1).vox.size];
                pRFSizes = pRFSize_NaN(~isnan(pRFSize_NaN));
                pRFSize = mean(pRFSizes);
    
                % Append to DF
                sub = [sub; sessions{i}];
                CenterXs = [CenterXs; CoM_x];
                CenterYs = [CenterYs; CoM_y];
                FWHMs = [FWHMs; FWHM];
                FWHM_radius = [FWHM_radius; fwhm_radius];
                ROI = [ROI; ROIs{m}];
                hemi = [hemi; hems{h}];
                size = [size; pRFSize];

            end
        end
    end
end

% Create a table from cell arrays
dataTable = table(sub, ROI, hemi, CenterXs, CenterYs, FWHMs, FWHM_radius, size);

% Define the CSV file path
csvFilePath = fullfile(dataDir, ['pRFCenters_FWHM_CoM_', exptName '_' group, '_' atlas 'ROIs.csv']);

% Write the table to a CSV file
writetable(dataTable, csvFilePath);

fprintf('Data has been saved to %s\n', csvFilePath);
