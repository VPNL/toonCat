function toonCat_getSizeEccLineFits_df(sessions,group,exptDir,exptName,atlas,resultsDir)
% This script gets a df using output from toon_loopSigmaVsEcc to plot size
% versus eccentricity and get the slopes and intercepts to use in R. It
% gets the linefits!

% JKY 2023

% Directories
dataDir = [exptDir resultsDir];

% Initialize cell arrays to store data
sub = {};
hemi = {};
ROI = {};
se = [];
size = [];
ecc = [];
roi_index = {};

% Load the saved data file
saveFile = ['toonCat_EccVsSigma_lineData_allHemi_' exptName '_' group, '_' atlas 'ROIs.mat'];
load(fullfile(dataDir,saveFile));

    % Loop through subjects
    for i = 1:length(sessions)
        % Loop through ROIs
        for roi = 1:length(lineData{i})
            for p = 1:21
                % Get size vs. ecc line values for this ROI and subject
                ecc_x = lineData{i}(roi).x(p);
                size_y = lineData{i}(roi).y(p);
                se_y = lineData{i}(roi).ysterr(p);
                
                % Get ROI and hemi for df purposes
                if (roi >= 1) & (roi <= 6)
                    hemisphere = 'rh'
                else
                    hemisphere = 'lh'
                end
    
                if (roi == 1) || (roi == 7)
                    roi_name = 'V1'
                elseif (roi == 2) || (roi == 8)
                    roi_name = 'V2'
                elseif (roi == 3) || (roi == 9)
                    roi_name = 'V3'
                elseif (roi == 4) || (roi == 10)
                    roi_name = 'hV4'
                elseif (roi == 5) || (roi == 11)
                    roi_name = 'VO'
                elseif (roi == 6) || (roi == 12)
                    roi_name = 'PHC'
                end
    
                % Append to DF
                sub = [sub; sessions{i}];
                hemi = [hemi; hemisphere];
                size = [size; size_y];
                ecc = [ecc; ecc_x];
                se = [se; se_y];
                ROI = [ROI; roi_name];
                roi_index = [roi_index, roi];
               
            end
        end
    end


% Create a table from cell arrays
dataTable = table(sub, ROI, hemi, ecc, size, se, roi_index');

% Define the CSV file path
csvFilePath = fullfile(dataDir, ['pRFSizeEcc_lineFits_' exptName '_' group, '_' atlas 'ROIs.csv']);

% Write the table to a CSV file
writetable(dataTable, csvFilePath);

fprintf('Data has been saved to %s\n', csvFilePath);
