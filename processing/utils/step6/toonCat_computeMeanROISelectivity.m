function toonCat_computeMeanROISelectivity(ROIs, hemis, sessions, listRuns)

% This script computes the nr of selective voxels for a given category or
% domain in a given ROI (typically VTC ROIs). It outputs both a .mat file
% and a .csv. Based off of Marisa's code in Localizer/code/selectiveVoxels!

% JKY July 2024

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% HOW TO USE THE SCRIPT:

% INPUTS:
% (1) ROIs
% Please specify the ROIs. Ex: toonCatROIs =
% {'pFus_faces_toon','mFus_faces_toon'}
%
% (2) hemis
% Please specify the hemispheres. Ex: hemis = {'rh', 'lh'}. These will be
% combined with the ROI inputs to form the complete label name
%
% (3) sessions
% Please specify the sessions (e.g., sessions 
% =  {'OS12_140729_time_01_1', 'OS12_140815_time_01_2'}
%
% (4) listRuns
% Enter the list of Runs to use for each session. For example:
% listRuns = [1 2; 2 3];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Specify the directories.
DataDir='/oak/stanford/groups/kalanit/biac2/kgs/projects/Kids_AcrossYears/FMRI/Localizer/data_toonCat/';
OutDir='/oak/stanford/groups/kalanit/biac2/kgs/projects/Kids_AcrossYears/FMRI/Localizer/results_toonCat/';

% Set parameters.
dataType= 3;
nrRuns = 3;
diskSize = '10';
resultsTable = [];

%% First get data and initalize mvs. 

for h=1:length(hemis)
    for r=1:length(ROIs)
            ROIname=[hemis{h} '_' ROIs{r}];
    
        for s=1:length(sessions)
            
            % get subject id
            session = sessions{s};
            sessionPath = [DataDir '/' session];
            cd(sessionPath)
            addpath(genpath(pwd))
            
            %% Check if this ROI exists in this participant
            if isfile([sessionPath '/3DAnatomy/ROIs/' ROIname '.mat'])
                    
                % init inplane view
                hi=initHiddenInplane(dataType, 1, [ROIname '.mat']);
    
                % runs might differ for sessions
                % runs = listRuns(s,:);
                runs = [1 2 3]; % JKY - all our subs have 3 runs (or more) so we don't need a separate list here
    
                % initialize mv structure for all runs combined.
                % mv = mv_init(view, <roi>, <scans>, <dt>, <preserveCoords>);
                 mv = mv_init(hi,ROIname,runs,dataType);
    
                 % make sure parameters are correct
                 eventsPerBlock=4;
    
                 params = mv.params;
                 params.eventAnalysis=1;
                 params.detrend = 1; % high-pass filter (remove the low frequency trend)
                 params.detrendFrames=20;
                 params.inhomoCorrection = 1; % divide by mean (transforms from raw scanner units to % signal)
                 params.temporalNormalization = 0; % no matching 1st temporal frame
                 params.ampType='betas';
                 params.glmHRF = 3; % SPM hrf
                 params.eventsPerBlock = eventsPerBlock;
                 params.lowPassFilter=0;
    
                 mv.params = params;

                % run glm at the level of each voxel
                 mv=mv_applyGlm(mv);
    
    
            
            %%  Compute Contrast and save nr of Selective voxels and mean TValues
            % From Parfile:
            % 1 	faceadult 
            % 2 	facechild
            % 3 	Body
            % 4 	Limb
            % 5 	Car 
            % 6 	Guitar
            % 7 	Place
            % 8 	House
            % 9 	Word
            % 10 	Number
             % Define category and domain names
                categoryNames = {'AdultFaces', 'ChildFaces', 'NoHeadBody', 'Limbs', ...
                    'Cars', 'Guitars', 'Corridors', 'Houses', 'Words', 'Number'};
                categoryNumbers = [1 2 3 4 5 6 7 8 9 10];
                domainNames = {'Faces', 'Bodies', 'Objects', 'Places', 'Chars'};
    
                if ismember(session, {'es103118', 'jw103018', 'mh102018', 'MN181023', 'TH181012'})
                    % For specific sessions, fill category fields with NaN and skip category analysis
                    for cN = 1:length(categoryNames)
                        dataSelectVoxels.([hemis{h} '_' ROIs{r}]).(sessions{s}).(['nr' categoryNames{cN}]) = nan;
                        dataSelectVoxels.([hemis{h} '_' ROIs{r}]).(sessions{s}).(['mean' categoryNames{cN}]) = nan;
                    end
                    
                    % Perform domain analysis
                    for dN = 1:length(domainNames)
                        activeDomain = dN;
                        sameDomainCategories = dN;
                        controlCategories = setdiff(1:5, sameDomainCategories);
                        
                        [stat_domains, ces_domains, vSig_domains, units_domains] = glm_contrast(mv.glm, sameDomainCategories, controlCategories, 't');
                        nrSelective_domains = length(find(stat_domains > 3));
                        mean_t_domains = mean(stat_domains);
                        
                        dataSelectVoxels.([hemis{h} '_' ROIs{r}]).(sessions{s}).(['nr' domainNames{dN}]) = nrSelective_domains;
                        dataSelectVoxels.([hemis{h} '_' ROIs{r}]).(sessions{s}).(['mean' domainNames{dN}]) = mean_t_domains;
                    end
                    
                else
                    % Perform category and domain analysis for other sessions
                    for cN = 1:length(categoryNames)
                        activeCategory = categoryNumbers(cN);
                        currentDomain = ceil(activeCategory / 2);
                        sameDomainCategories = [currentDomain * 2 - 1, currentDomain * 2];
                        controlCategories = setdiff(categoryNumbers, sameDomainCategories);
                        
                        %% category contrasts
                        [stat_categories, ces_categories, vSig_categories, units_categories] = glm_contrast(mv.glm, activeCategory, controlCategories, 't');
                        nrSelective_categories = length(find(stat_categories > 3));
                        mean_t_categories = mean(stat_categories);
                        
                        dataSelectVoxels.([hemis{h} '_' ROIs{r}]).(sessions{s}).(['nr' categoryNames{cN}]) = nrSelective_categories;
                        dataSelectVoxels.([hemis{h} '_' ROIs{r}]).(sessions{s}).(['mean' categoryNames{cN}]) = mean_t_categories;
                        
                        %% domain contrasts
                        [stat_domains, ces_domains, vSig_domains, units_domains] = glm_contrast(mv.glm, sameDomainCategories, controlCategories, 't');
                        nrSelective_domains = length(find(stat_domains > 3));
                        mean_t_domains = mean(stat_domains);
                        
                        dataSelectVoxels.([hemis{h} '_' ROIs{r}]).(sessions{s}).(['nr' domainNames{currentDomain}]) = nrSelective_domains;
                        dataSelectVoxels.([hemis{h} '_' ROIs{r}]).(sessions{s}).(['mean' domainNames{currentDomain}]) = mean_t_domains;
                    end
                end
                
            else
                categoryNames = {'AdultFaces', 'ChildFaces', 'NoHeadBody', 'Limbs', ...
                    'Cars', 'Guitars', 'Corridors', 'Houses', 'Words', 'Number'};
                categoryNumbers = [1 2 3 4 5 6 7 8 9 10];
                domainNames = {'Faces', 'Bodies', 'Objects', 'Places', 'Chars'};
                categoriesAndDomains = [categoryNames, domainNames];
                prefixList = {'nr', 'mean'};
                
                for pdx = 1:length(prefixList)
                    prefix = prefixList{pdx};
                    for idx = 1:length(categoriesAndDomains)
                        dataSelectVoxels.([hemis{h} '_' ROIs{r}]).(sessions{s}).([prefix categoriesAndDomains{idx}]) = nan;
                    end
                end
            end
            
            clear global
            clearvars -except diskSize categoryNames domainNames resultsTable DataDir OutDir dataType ROIs numconds eventsPerBlock nrRuns s r h session sessions listRuns ROIname dataSelectVoxels hemis
    
        end        
    
            % Save out .mat file        
            dataFileName = ['dataSelectVoxels_' num2str(nrRuns) 'Runs'];
            if nrRuns == 3
                dataIndFilePath=fullfile([OutDir '/selectiveVoxels/threeRuns/' dataFileName]);
            elseif nrRuns == 2
                dataIndFilePath=fullfile([OutDir '/selectiveVoxels/twoRuns/' dataFileName]);
            end

            save(dataIndFilePath, 'dataSelectVoxels')

            % create table for csv - FIX THIS!
            for s = 1:length(sessions)
                session = sessions{s};
                hemi = hemis{h};
                ROI = ROIs{r};
                dataRow = {session, hemi, ROI};
                
                for cN = 1:length(categoryNames)
                    dataRow = [dataRow, dataSelectVoxels.([hemis{h} '_' ROIs{r}]).(session).(['nr' categoryNames{cN}]), dataSelectVoxels.([hemis{h} '_' ROIs{r}]).(session).(['mean' categoryNames{cN}])];
                end
                
                for dN = 1:length(domainNames)
                    dataRow = [dataRow, dataSelectVoxels.([hemis{h} '_' ROIs{r}]).(session).(['nr' domainNames{dN}]), dataSelectVoxels.([hemis{h} '_' ROIs{r}]).(session).(['mean' domainNames{dN}])];
                end
                
                resultsTable = [resultsTable; dataRow];
            end
        
    end
end

% Convert the results to a table
columnNames = [{'Session', 'Hemi', 'ROI'}];
for cN = 1:length(categoryNames)
    columnNames = [columnNames, ['nr' categoryNames{cN}], ['mean' categoryNames{cN}]];
end
for dN = 1:length(domainNames)
    columnNames = [columnNames, ['nr' domainNames{dN}], ['mean' domainNames{dN}]];
end

resultsTable = cell2table(resultsTable, 'VariableNames', columnNames);

% Save the results table as a CSV file
csvFileName = [OutDir 'csv/catSelectivity_' num2str(nrRuns) 'Runs_diskROIs_' diskSize 'mm_new.csv'];
writetable(resultsTable, csvFileName);
disp('CSV saved in results folder');

end