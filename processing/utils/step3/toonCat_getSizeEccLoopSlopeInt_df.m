function toon_getSizeEccLoopSlopeInt_df(sessions,group,exptDir,exptName,atlas,resultsDir)
% This script gets a df using output from toonCat_loopSigmaVsEcc to plot size
% versus eccentricity and get the slopes and intercepts to use in R.
%
% JKY 2023

% Directories
dataDir = [exptDir resultsDir];

% Initialize cell arrays to store data
sub = {};
hemi = {};
ROI = {};
slope = [];
intercept = [];
size = [];
ecc = [];
roi_index = {};

% Load the saved data file
saveFile = ['toonCat_EccVsSigma_lineData_allHemi_' exptName '_' group, '_' atlas 'ROIs.mat'];
load(fullfile(dataDir, saveFile));

    % Loop through subjects
    for i = 1:length(sessions)
        % Loop through ROIs
        for roi = 1:length(lineData{i})

            % Get size vs. ecc slope and intercept for this ROI and subject
            if lineData{i}(roi).error == 0
                slope_sub = lineData{i}(roi).line(1);
                intercept_sub = lineData{i}(roi).line(2);
                avgSize = nanmean(lineData{i}(roi).sigma);
                avgEcc = nanmean(lineData{i}(roi).ecc);
                names = split(lineData{i}(roi).roi, ".");
                roi_name = names(2,:);
                hemisphere = names(1,:);
    
                % Append to DF
                sub = [sub; sessions{i}];
                hemi = [hemi; hemisphere];
                slope = [slope; slope_sub];
                intercept = [intercept; intercept_sub];
                size = [size; avgSize];
                ecc = [ecc; avgEcc];
                ROI = [ROI; roi_name];
            end

        end
    end


% Create a table from cell arrays
dataTable = table(sub, ROI, hemi, slope, intercept, ecc, size);

% Define the CSV file path
csvFilePath = fullfile(dataDir, ['pRF_SizeEcc_' exptName '_' group, '_' atlas 'ROIs.csv']);

% Write the table to a CSV file
writetable(dataTable, csvFilePath);

fprintf('Data has been saved to %s\n', csvFilePath);
