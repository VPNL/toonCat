function toonCat_getFWHMCoV_df(sessions,hemis,group,exptDir,exptName,atlas,toonCatROIs,resultsDir,ve_cutoff, fieldRange,fieldRange2plot,norm,thresh)
% This script calculates the full-width half max for each of the subjects,
% hemispheres, and ROIs and stores it in a table that can be exported to R
% Markdown for statistical analysis. It also has been edited to include the
% pRF center of mass (x and y coordinates calculated with the FWHM), and
% the included and total voxels driven by toonotopy. This is calculated
% from the coverage map, not the centers. It also includes the proportion
% of voxels included in the analysis.
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
cd(dataDir);

% Initialize cell arrays to store data
subjectNames = {};
hemispheres = {};
ROIs = {};
FWHMs = [];
FWHMs_upper = [];
FWHMs_lower = [];
FWHMs_central5 = [];
FWHMs_contra = [];
FWHMs_ipsi = [];
FWHMs_central10 = [];
FWHMs_upperContra = [];
FWHMs_lowerContra = [];
FWHMs_upperIpsi = [];
FWHMs_lowerIpsi = [];
CoM_Xs = [];
CoM_Ys = [];
CenterX = [];
CenterY = [];
IncludedVox = [];
TotalVox = [];
Proportion20 = [];

% Loop through the loaded data
for h = 1:length(hemis)
    % Load the saved data file
    if hemis{h} == 'lh'
        load(['lh.coverage_data_ve' num2str(ve_cutoff*100) '_' num2str(fieldRange) '_voxthresh' num2str(thresh) '_' exptName '_' group '_' atlas 'ROIs.mat']);

    else
        load(['rh.coverage_data_ve' num2str(ve_cutoff*100) '_' num2str(fieldRange) '_voxthresh' num2str(thresh) '_' exptName '_' group '_' atlas 'ROIs.mat']);
    end

    for m = 1:length(toonCatROIs)
        % Extract the data for the current hemisphere and ROI
        data = fits(m);  
        hemi = hemis{h};
        ROI = toonCatROIs{m};
        
        % Loop through subjects and extract FWHM values
        for i = 1:length(sessions)
            % Extract FWHM and centers for the current subject, hemisphere, and ROI
            % NOTE: this pulls UNSCALED vales; scaled values
            fwhm = data.fwhm(:, i);
            fwhm_upper = data.fwhm_upper(:,i);
            fwhm_lower = data.fwhm_lower(:,i);
            fwhm_central5 = data.fwhm_central5(:,i);
            fwhm_contra = data.fwhm_contra(:,i);
            fwhm_central10 = data.fwhm_central10(:,i);
            fwhm_ipsi = data.fwhm_ipsi(:,i);
            fwhm_upperContra = data.fwhm_upperContra(:,i);
            fwhm_lowerContra = data.fwhm_lowerContra(:,i);
            fwhm_upperIpsi = data.fwhm_upperIpsi(:,i);
            fwhm_lowerIpsi = data.fwhm_lowerIpsi(:,i);
            center_x = data.center_x(:, i);
            center_y = data.center_y(:, i);
            CoM_x = data.CoM_x(:,i);
            CoM_y = data.CoM_y(:,i);
            includedvox = data.includedvox(:, i);
            totalvox = data.totalvox(:, i);
            proportion20 = data.proportion20(:, i);

            % for v = 1:length(data.vox)
            %     % Check eccentricity first
            %     if data.vox(v).eccen <= fieldRange2plot
            % 
                    % Check if the FWHM value meets the thresholds
                    if ~isnan(fwhm) && data.includedvox(:, i) >= thresh
                        % Extract subject name
                        subject = sessions{i};
                        
                        % Append data to cell arrays
                        subjectNames{end+1} = subject;
                        hemispheres{end+1} = hemi;
                        ROIs{end+1} = ROI;
                        FWHMs(end+1) = fwhm;
                        FWHMs_upper(end+1) = fwhm_upper;
                        FWHMs_lower(end+1) = fwhm_lower;
                        FWHMs_central5(end+1) = fwhm_central5;
                        FWHMs_contra(end+1) = fwhm_contra;
                        FWHMs_central10(end+1) = fwhm_central10;
                        FWHMs_ipsi(end+1) = fwhm_ipsi;
                        FWHMs_upperContra(end+1) = fwhm_upperContra;
                        FWHMs_lowerContra(end+1) = fwhm_lowerContra;
                        FWHMs_upperIpsi(end+1) = fwhm_upperIpsi;
                        FWHMs_lowerIpsi(end+1) = fwhm_lowerIpsi;
                        CoM_Xs(end+1) = CoM_x;
                        CoM_Ys(end+1) = CoM_y;
                        CenterX(end+1) = center_x;
                        CenterY(end+1) = center_y;
                        IncludedVox(end+1) = includedvox;
                        TotalVox(end+1) = totalvox;
                        Proportion20(end+1) = proportion20;

                    elseif includedvox == 0
                        % Extract subject name
                        subject = sessions{i};
                        
                        % Fill data with NA or zeros as appropriate
                        subjectNames{end+1} = subject;
                        hemispheres{end+1} = hemi;
                        ROIs{end+1} = ROI;
                        FWHMs(end+1) = NaN;
                        FWHMs_upper(end+1) = NaN;
                        FWHMs_lower(end+1) = NaN;
                        FWHMs_central5(end+1) = NaN;
                        FWHMs_contra(end+1) = NaN;
                        FWHMs_central10(end+1) = NaN;
                        FWHMs_ipsi(end+1) = NaN;
                        FWHMs_upperContra(end+1) = NaN;
                        FWHMs_lowerContra(end+1) = NaN;
                        FWHMs_upperIpsi(end+1) = NaN;
                        FWHMs_lowerIpsi(end+1) = NaN;
                        CoM_Xs(end+1) = NaN;
                        CoM_Ys(end+1) = NaN;
                        CenterX(end+1) = NaN;
                        CenterY(end+1) = NaN;
                        IncludedVox(end+1) = 0; 
                        TotalVox(end+1) = 0;
                        Proportion20(end+1) = NaN; 
                    end
        end
    end
end

% Create a table from the extracted data
dataTable = table(subjectNames', hemispheres', ROIs', FWHMs', FWHMs_upper', FWHMs_lower', FWHMs_central5', FWHMs_central10',FWHMs_contra', FWHMs_ipsi',FWHMs_upperContra', FWHMs_lowerContra', FWHMs_upperIpsi', FWHMs_lowerIpsi',CoM_Xs', CoM_Ys', CenterX', CenterY', IncludedVox', TotalVox', Proportion20', 'VariableNames', {'subject', 'hemi', 'ROI', 'fwhm', 'fwhm_upper', 'fwhm_lower', 'fwhm_central5', 'fwhm_central10','fwhm_contra','fwhm_ipsi','fwhm_upperContra', 'fwhm_lowerContra', 'fwhm_upperIpsi', 'fwhm_lowerIpsi', 'CoM_x', 'CoM_y', 'centerX', 'centerY', 'includedvox','totalvox', 'proportion20'});

% Specify the path and filename for the CSV file
csvFileName = ['pRFCoVCenters_FWHM_CoM_VoxProp20' exptName '_' group '_' atlas 'ROIs_zerosSize_fwhm.csv'];

% Save the table as a CSV file
writetable(dataTable, csvFileName);

% Display a message indicating that the data has been saved
disp(['Data saved as ' csvFileName]);
