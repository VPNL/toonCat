function toonCat_plotAllCenters(sessions,hemis,group,exptDir,exptName,atlas,ROIs)
%
% Plots the pRF centers for voxels across all subjects
% (also stores the average centers for subsequent use)
%
%   sessions: list of sessions/subs
%   hemi: lh and/or rh, array
%   group: name of age group as a string
%   exptDir: path to the experiment directory
%   exptName: expt name and version, used for file name
%   atlas: ROI atlas (toon, wang, cat)
%   ROIs: array of ROI names to include in the df
%
% DF 2019 toon_plotAllCenters.m
% Adapted by JKY 2023
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Directories
sessionDir = [exptDir 'data'];
dataDir = [exptDir 'results/jewelia'];
figDir = [exptDir 'results/jewelia'];

% Parameter Setup
ve_cutoff = .20;
fieldRange = 20;
fieldRange2plot = 20;
norm = 0;
thresh = 0; %just to pull in files
sigThresh = 0.21; % size threshold
eThresh = [0 fieldRange];
voxThresh = 10; % minimum number of voxels per ROI
vfc.fieldRange = fieldRange;
retROISuffix = ['_' atlas];

%% load prf sets
set(1) = load(fullfile(dataDir,['rh.pRFset_' num2str(fieldRange) '_ve' num2str(ve_cutoff*100) '_voxthresh' num2str(voxThresh) '_plotRange' num2str(fieldRange2plot) '_' exptName '_' group '_' atlas 'ROIs.mat'])); 
set(2) = load(fullfile(dataDir,['lh.pRFset_' num2str(fieldRange) '_ve' num2str(ve_cutoff*100) '_voxthresh' num2str(voxThresh) '_plotRange' num2str(fieldRange2plot) '_' exptName '_' group '_' atlas 'ROIs.mat'])); 

[~, xydeg_idx] = ismember('XYdeg', fieldnames(set(1).subj(1).roi(1).fits.vox)); %for reorg

%initialize
for h = 1:2
    for r = 1:length(ROIs)
        hemi(h).allRoi(r).vox = [];
    end
end

for h = 1:2
    for i = 1:length(sessions)
        for r = 1:length(ROIs)
            vox = [];
            %get average center per sub
            for v = 1:length(set(h).subj(i).roi(r).fits.vox)
               % remove voxels that have ecc > 20
               if set(h).subj(i).roi(r).fits.vox(v).eccen <= fieldRange2plot
                    vox = [vox set(h).subj(i).roi(r).fits.vox(v)];
               end
            end
            if ~isempty(vox) && length(vox) >= thresh
                temp = struct2cell(vox.').'; XYdeg = temp(:, xydeg_idx); clear temp;
                XYdeg(cellfun(@(XYdeg) any(isnan(XYdeg)),XYdeg))=[]; %remove nans
                vals = cell2mat(XYdeg); 
                x_val(h,i,r) = nanmean(vals(:,1));
                y_val(h,i,r) = nanmean(vals(:,2));
            else
                x_val(h,i,r) = NaN;
                y_val(h,i,r) = NaN;
            end
            
            % Remove voxels with ecc bigger than plot range
            for v = 1:length(set(h).subj(i).roi(r).fits.vox)
                if set(h).subj(i).roi(r).fits.vox(v).eccen <= fieldRange2plot
                    hemi(h).allRoi(r).vox = [hemi(h).allRoi(r).vox set(h).subj(i).roi(r).fits.vox(v)];
                end
            end
        end
    end
end

saveMatFile = fullfile(dataDir,['average_prf_centers_' num2str(fieldRange) '_ve' num2str(ve_cutoff*100) '_plotRange' num2str(fieldRange2plot) '_' exptName '_' group '_' atlas 'ROIs.mat']);
save(saveMatFile, 'x_val','y_val');
%% Now plot the centers

% Colors for combined toon ROIs
% colors_left = [[142/255, 94/255, 127/255];...%V1
%      [182/255, 92/255, 121/255];...%V2
%      [255/255, 198/255, 105/255];...%V3
%      [168/255, 175/255, 83/255];...%hV4
%      [96/255, 141/255, 108/255];...%VO
%      [101/255, 168/255, 156/255]];%PH
% 
% colors_right = [[90/255, 21/255, 71/255];...
%         [146/255, 5/255, 61/255];...
%         [255/255, 174/255, 8/255];...
%         [107/255, 116/255, 0/255];...
%         [14/255, 90/255, 46/255];...
%         [0/255, 129/255, 111/255]];

% Colors for category ROIs
% colors_right = [[142/255, 94/255, 127/255];...%V1
%      [182/255, 92/255, 121/255];...%V2
%      [255/255, 198/255, 105/255];...%V3
%      [168/255, 175/255, 83/255];...%hV4
%      [96/255, 141/255, 108/255];...%VO
%      [101/255, 168/255, 156/255];...%PHC
%     [153/255, 0/255, 0/255];...%pFus-faces
%     [255/255, 0/255, 0/255];...%mFus-faces
%     [255/255, 45/255, 89/255];...%IOG-faces
%     [0/255, 0/255, 102/255];...%pOTS-words
%     [1/255, 150/255, 255/255];...%mOTS-words
%     [0/255, 224/255, 255/255];...%IOS-words
%     [204/255, 204/255, 51/255];...%OTS-bodies
%     [55/255, 68/255, 15/255];...%VO-places
%     [51/255, 102/255, 0/255];...%CoS-places
% 
%     ]; 
% 
% colors_left = [[90/255, 21/255, 71/255];...
%         [146/255, 5/255, 61/255];...
%         [255/255, 174/255, 8/255];...
%         [107/255, 116/255, 0/255];...
%         [14/255, 90/255, 46/255];...
%         [0/255, 129/255, 111/255];...
%         [183/255, 96/255, 85/255];...
%         [255/255, 113/255, 95/255];...
%         [255/255, 116/255, 40/255];...
%         [74/255, 92/255, 163/255];...
%         [161/255, 226/255, 255/255];...
%         [123/255, 240/255, 255/255];...
%         [255/255, 255/255, 0/255];...
%         [116/255, 124/255, 90/255];...
%         [102/255, 255/255, 0/255];...
% ];

if strcmp(atlas,'toon')
%     %Colors for category ROIs
%     colors_right = [[142/255, 94/255, 127/255];...%V1
%          [182/255, 92/255, 121/255];...%V2
%          [255/255, 198/255, 105/255];...%V3
%          [168/255, 175/255, 83/255];...%hV4
%          [96/255, 141/255, 108/255];...%VO
%          [101/255, 168/255, 156/255];...%PHC
%          [255/255, 113/255, 95/255];...…%pFus-faces
%         [74/255, 92/255, 163/255];...…%pOTS-words
%         [102/255, 255/255, 0/255];...…%CoS-places
%         [255/255, 116/255, 140/255];...…%mFus-faces
%        [255/255, 255/255, 0/255];...…%OTS-bodies
%        [161/255, 226/255, 255/255];...…%mOTS-words
%         [183/255, 96/255, 85/255];...…%pFus-faces
%         [74/255, 92/255, 163/255];...…%pOTS-words
%         [102/255, 255/255, 0/255];...…%CoS-places
%         [255/255, 113/255, 95/255];...…%mFus-faces
%        [255/255, 255/255, 0/255];...…%OTS-bodies
%        [161/255, 226/255, 255/255];...…%mOTS-words
% ];
% 
% 
%     colors_left = [[90/255, 21/255, 71/255];...…%V1
%             [146/255, 5/255, 61/255];...…%V2
%             [255/255, 174/255, 8/255];...…%V3
%             [107/255, 116/255, 0/255];...…%hV4
%             [14/255, 90/255, 46/255];...…%VO
%             [0/255, 129/255, 111/255];...…%PHC
%             [255/255, 0/255, 0/255];...%pFus-faces
%             [0/255, 0/255, 102/255];...%pOTS-words
%             [51/255, 102/255, 0/255];...%CoS-places
%             [255/255, 45/255, 89/255];...%mFus-faces
%            [204/255, 204/255, 51/255];...%OTS-bodies
%             [1/255, 150/255, 255/255];%mOTS-words
%             [153/255, 0/255, 0/255];...%pFus-faces
%             [0/255, 0/255, 102/255];...%pOTS-words
%         [51/255, 102/255, 0/255];...%CoS-places
%             [255/255, 0/255, 0/255];...%mFus-faces
%            [204/255, 204/255, 51/255];...%OTS-bodies
%             [1/255, 150/255, 255/255];...%mOTS-words
%             ]; 
 %Colors for category ROIs
    colors_right = [[171/255,21/255,0/255];...%pFus
        [247/255,44/255,90/255];...%mFus
        [128/255,116/255,26/255];...%OTS
        [1/255,11/255,95/255];...%pOTS
        [0/255,141/255,218/255];...%mOTS
        [0/255,62/255,10/255]%CoS
        ];

    
    colors_left = [[255/255,119/255,104/255];...%pFus
        [255/255,181/255,193/255];...%mFus
        [255/255,251/255,3/255];...%OTS
        [9/255,49/255,255/255];...%pOTS
        [0/255,141/255,218/255];...%mOTS
        % [91/255,219/255,251/255];...%mOTS
        [0/255,205/255,5/255]%CoS
                    ]; 


elseif strcmp(atlas,'toon_JC')
    % Colors lateral
    colors_right = [
        [129/255, 0/255, 0/255];...%IOG
        %[187/255,90.79/255];...%pSTS
        [195/255,146/255,2/255];...%ITG
        [254/255,166/255,13/255];...%LOS
        %[157/255,128/255,81/255];...%MTG
        [79/255,103/255,96/255];...%MOG
        [75/255,101/255,80/255]%IPS
        
    ];
    
    colors_left = [
        [198/255,87/255,89/255];...%IOG
        %[255/255,151/255,121/255];...%pSTS
        [255/255,226/255,42/255];...%ITG
        [249/255,219/255,96/255];...%LOS
       % [235/255,186/255,64/255];...%MTG
        [180/255,199/255,174/255];...%MOG
        [82/255,176/255,110/255]%IPS

    ];
elseif strcmp(atlas, 'adultAvg_probMap_toonCat')
    % Colors lateral
    colors_left = [[255/255,151/255,121/255];...%pSTS
        [255/255,239/255,129/255]%MTG
    ];
    
    colors_right = [[187/255,90/255,79/255];...%pSTS
        [250/255,192/255,11/255]%MTG
    ];
else
    disp('No atlas defined')
end

% Define the color array
colors = [colors_left; colors_right];

% Loop through the ROIs
for r = 1:length(ROIs)
    f = figure('Position',[100 100 600 600],'color','w'); % Create a new figure

    xlim([-vfc.fieldRange vfc.fieldRange])
    ylim([-vfc.fieldRange vfc.fieldRange])

    numSubjects = size(x_val, 2);  % Total number of subjects
    
    numSubsWithDataRH = sum(~isnan(x_val(1, :, r)), 'all');
    numSubsWithDataLH = sum(~isnan(x_val(2, :, r)), 'all');
    
    disp(['ROI: ' ROIs{r}]);
    disp(['RH: N = ' num2str(numSubsWithDataRH) ' / ' num2str(numSubjects)]);
    disp(['LH: N = ' num2str(numSubsWithDataLH) ' / ' num2str(numSubjects)]);
    
    % Plot data for the right hemisphere (RH) if available
    if r == 10
        % If there is no data for RH, plot only LH data (if available)
     
            for h = 2 % left hemi
                color = colors_left(r,:);
                
                temp = struct2cell(hemi(h).allRoi(r).vox.').';
                XYdeg = temp(:, xydeg_idx);
                clear temp;

                XYdeg(cellfun(@(XYdeg) any(isnan(XYdeg)), XYdeg)) = []; % remove nans
                vals = cell2mat(XYdeg); 

                scatter(vals(:,1),vals(:,2),15,color); hold on;
            end
            
            % Additional plotting settings for LH
            p.fillColor='w';
            p.ringTicks = [0, 5, 10, 20];
            p.gridColor = [0 0 0];
            p.color = 'k';
            p.fontSize = 18;
            polarPlot([], p);
            clim([0 1]);

            % Add the N value to the plot for LH
            %text(-vfc.fieldRange + 45, vfc.fieldRange - 2, ['LH: N = ' num2str(numSubsWithDataLH)], 'FontSize', 25, 'Color', 'k', 'HorizontalAlignment', 'right');

            % Save the figure for LH
            saveFigFile = fullfile(figDir, 'centers', group, ['LH_' ROIs{r} '_pRF_centers_' num2str(fieldRange2plot) '_ve' num2str(ve_cutoff*100) '_' exptName '_' group '_' atlas 'ROIs_noN.png']); 
            saveas(gcf, saveFigFile);
    elseif numSubsWithDataRH > 0 & numSubsWithDataLH > 0 
        for h = 1:2
            if h == 1 % right hemi
                color = colors_right(r,:);
            elseif h == 2 % left hemi
                color = colors_left(r,:);
            end

            temp = struct2cell(hemi(h).allRoi(r).vox.').';
            XYdeg = temp(:, xydeg_idx);
            clear temp;

            XYdeg(cellfun(@(XYdeg) any(isnan(XYdeg)), XYdeg)) = []; % remove nans
            vals = cell2mat(XYdeg); 

            scatter(vals(:,1),vals(:,2),15,color); hold on;
        end

        % Additional plotting settings and saving the figure...
        p.fillColor='w';
        p.ringTicks = [0, 5, 10, 20];
        p.gridColor = [0 0 0];
        p.color = 'k';
        p.fontSize = 18;
        polarPlot([], p);
        clim([0 1]);


        % Add the N values to the plot
        %text(-vfc.fieldRange + 40, vfc.fieldRange - 2, ['N = ' num2str(numSubsWithDataLH)], 'FontSize', 25, 'Color', 'k', 'HorizontalAlignment', 'right');
        %text(-vfc.fieldRange + 10, vfc.fieldRange - 2, ['N = ' num2str(numSubsWithDataRH)], 'FontSize', 25, 'Color', 'k', 'HorizontalAlignment', 'right');

        % Save the figure
        saveFigFile = fullfile(figDir, 'centers', group, [ROIs{r} '_pRF_centers_' num2str(fieldRange2plot) '_ve' num2str(ve_cutoff*100) '_' exptName '_' group '_' atlas 'ROIs_noN.png']); 
        saveas(gcf, saveFigFile);
    elseif numSubsWithDataLH > 0
        % If there is no data for RH, plot only LH data (if available)
     
            for h = 2 % left hemi
                color = colors_left(r,:);
                
                temp = struct2cell(hemi(h).allRoi(r).vox.').';
                XYdeg = temp(:, xydeg_idx);
                clear temp;

                XYdeg(cellfun(@(XYdeg) any(isnan(XYdeg)), XYdeg)) = []; % remove nans
                vals = cell2mat(XYdeg); 

                scatter(vals(:,1),vals(:,2),15,color); hold on;
            end
            
            % Additional plotting settings for LH
            p.fillColor='w';
            p.ringTicks = [0, 5, 10, 20];
            p.gridColor = [0 0 0];
            p.color = 'k';
            p.fontSize = 18;
            polarPlot([], p);
            clim([0 1]);

            % Add the N value to the plot for LH
            text(-vfc.fieldRange + 45, vfc.fieldRange - 2, ['LH: N = ' num2str(numSubsWithDataLH)], 'FontSize', 25, 'Color', 'k', 'HorizontalAlignment', 'right');

            % Save the figure for LH
            saveFigFile = fullfile(figDir, 'centers', group, ['LH_' ROIs{r} '_pRF_centers_' num2str(fieldRange2plot) '_ve' num2str(ve_cutoff*100) '_' exptName '_' group '_' atlas 'ROIs.png']); 
            saveas(gcf, saveFigFile);
    elseif numSubsWithDataRH > 0
        % If there is no data for LH, plot only RH data (if available)
        
            for h = 1 % right hemi
                color = colors_right(r,:);
                
                temp = struct2cell(hemi(h).allRoi(r).vox.').';
                XYdeg = temp(:, xydeg_idx);
                clear temp;

                XYdeg(cellfun(@(XYdeg) any(isnan(XYdeg)), XYdeg)) = []; % remove nans
                vals = cell2mat(XYdeg); 

                scatter(vals(:,1),vals(:,2),15,color); hold on;
            end
            
            % Additional plotting settings for LH
            p.fillColor='w';
            p.ringTicks = [0, 5, 10, 20];
            p.gridColor = [0 0 0];
            p.color = 'k';
            p.fontSize = 18;
            polarPlot([], p);
            clim([0 1]);

            % Add the N value to the plot for LH
            text(-vfc.fieldRange + 10, vfc.fieldRange - 2, ['RH: N = ' num2str(numSubsWithDataRH)], 'FontSize', 25, 'Color', 'k', 'HorizontalAlignment', 'right');

            % Save the figure for LH
            saveFigFile = fullfile(figDir, 'centers', group, ['RH_' ROIs{r} '_pRF_centers_' num2str(fieldRange2plot) '_ve' num2str(ve_cutoff*100) '_' exptName '_' group '_' atlas 'ROIs.png']); 
            saveas(gcf, saveFigFile);
        else
            disp('No data for either hemisphere. Skipping plot.');
        end
    end

    % Close the figure
    close(f);
end
