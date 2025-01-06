% function toonCat_makeSizeEccPlots(rois, sizeEccFile, roiSubset)
%     % Constants
%     AGE_THRESHOLD = 18;
%     X_POINTS = 0:5:20;
% 
%     % Load data
%     [data] = loadData(sizeEccFile);
% 
%     % Process data for each ROI
%     for i = 1:numel(rois)
%         roi = rois{i};
%         [adults, kids] = processData(data, AGE_THRESHOLD, roi);
%         plotResults(adults, kids, X_POINTS, roi);
%     end
% 
%     % Save individual plots
% 
%     savePlot();
% 
% end

function toonCat_makeSizeEccPlots(rois, sizeEccFile, ~)
    % Constants
    AGE_THRESHOLD = 18;
    X_POINTS = 0:5:20;

    % Load data
    [data] = loadData(sizeEccFile);

    % Initialize storage for results
    allAdults = [];
    allKids = [];

    % Process data for each ROI
    for i = 1:numel(rois)
        roi = rois{i};
        [adults, kids] = processData(data, AGE_THRESHOLD, roi);
        allAdults{i} = adults;
        allKids{i} = kids;
    end

    % Plot results on a single plot
    plotResults(allAdults, allKids, X_POINTS, rois);

    % Save the combined plot
    savePlot();
end


function [data] = loadData(sizeEccFile)
    curdir = pwd;
    dataDir = fullfile(curdir);
    fileName = sizeEccFile;
    load(fullfile(dataDir, fileName));
    data = lineDataWithAgeSession;    
end

function [adults, kids] = processData(data, ageThreshold, roi)
    adults = struct('slope', [], 'intercept', [], 'varexp', []);
    kids = struct('slope', [], 'intercept', [], 'varexp', []);
    data = data.lineData;

    for i = 1:numel(data)
        age = data{i}(1,1).age;
        isKid = age < ageThreshold;
        
        for m = 1:numel(data{i})
            currentRoi = data{i}(1,m).roi;
            if contains(currentRoi, roi)
                variance = data{i}(1,m).variance(data{i}(1,m).variance >= 0.1);
                line = data{i}(1,m).line;

                if isempty(variance) || isempty(line)
                    continue;
                end

                if line(1) > 0 && line(2) > 0 % Valid slope and intercept
                    if isKid
                        kids.slope(end + 1) = line(1);
                        kids.intercept(end + 1) = line(2);
                        kids.varexp(end + 1) = mean(variance);
                    else
                        adults.slope(end + 1) = line(1);
                        adults.intercept(end + 1) = line(2);
                        adults.varexp(end + 1) = mean(variance);
                    end
                end
            end
        end
    end
end

% function plotResults(adults, kids, xPoints, roi)
%     % Create a figure for individual plots
%     figure('Position',[100 100 1550 475],'Color','w');
%     plotROI(adults, kids, xPoints, roi);
%     title(roi, 'fontsize', 14);
%     % Save individual plot
%     saveas(gcf, fullfile(pwd, 'output', ['slopes_', roi, '_individual_SD.png']));
% end

function plotResults(allAdults, allKids, xPoints, rois)
    % Create a figure for combined plots
    figure('Position', [100, 100, 900, 600], 'Color', 'w');
    hold on; % Keep plot from refreshing

    % Loop over each ROI and plot
    for i = 1:length(rois)
        plotROI(allAdults{i}, allKids{i}, xPoints, rois{i});
    end
    
    % Additional settings
    legend show; % Show legend
    xlabel('Eccentricity (dva)', 'FontSize', 30);
    ylabel('pRF size (dva)', 'FontSize', 30);
    title('Combined pRF Size Across ROIs', 'FontSize', 15);
    hold off; % Release plot hold
    
    % Save the combined plot
    saveas(gcf, fullfile(pwd, 'output', 'combined_ROIs.png'));
end


function plotROI(adults, kids, xPoints, roi)
    % Define base ROI names without hemisphere
    %roiNames = {'lh.V1_toon', 'lh.V2_toon', 'lh.V3_toon', 'lh.hV4_toon', 'lh.VO_toon'} %, 'lh.PHC_toon', 'lh.pFus_faces_toon', 'lh.pOTS_words_toon', 'lh.CoS_places_toon', 'lh.mFus_faces_toon', 'lh.OTS_bodies_toon', 'lh.mOTS_words_toon', 'lh.pFus_kubotaMPM_toon', 'lh.pOTS_kubotaMPM_toon', 'lh.PPA_kubotaMPM_toon', 'lh.mFus_kubotaMPM_toon', 'lh.OTS_kubotaMPM_toon', 'lh.mOTS_kubotaMPM_toon'};
    roiNames = {'rh.V1_toon', 'rh.V2_toon', 'rh.V3_toon'};%, 'rh.hV4_toon', 'rh.VO_toon'} %, 'rh.PHC_toon', 'rh.pFus_faces_toon', 'rh.pOTS_words_toon', 'rh.CoS_places_toon', 'rh.mFus_faces_toon', 'rh.OTS_bodies_toon', 'rh.mOTS_words_toon', 'rh.pFus_kubotaMPM_toon', 'rh.pOTS_kubotaMPM_toon', 'rh.PPA_kubotaMPM_toon', 'rh.mFus_kubotaMPM_toon', 'rh.OTS_kubotaMPM_toon', 'rh.mOTS_kubotaMPM_toon'};
    %roiNames = {'rh.IOG_faces_toon_JC' 'rh.pSTS_faces_toon_JC' 'rh.ITG_limbs_toon_JC' 'rh.LOS_limbs_toon_JC' 'rh.MTG_limbs_toon_JC' 'rh.IPSl_places_toon_JC' 'rh.IPSm_places_toon_JC' 'rh.MOG_places_toon_JC'};
    %roiNames = {'lh.IOG_faces_toon_JC' 'lh.pSTS_faces_toon_JC' 'lh.ITG_limbs_toon_JC' 'lh.LOS_limbs_toon_JC' 'lh.MTG_limbs_toon_JC' 'lh.IPSl_places_toon_JC' 'lh.IPSm_places_toon_JC' 'lh.MOG_places_toon_JC'};

    % Define RGB values for adults and kids
    adultRGBVals = {[142/255, 94/255, 127/255]; [182/255, 92/255, 121/255]; [255/255, 198/255, 105/255]} % [168/255, 175/255, 83/255]; [96/255, 141/255, 108/255]}; %[101/255, 168/255, 156/255]; [153/255, 0/255, 0/255]; [0/255, 0/255, 102/255]; [51/255, 102/255, 0/255]; [255/255, 0/255, 0/255]; [204/255, 204/255, 51/255]; [1/255, 150/255, 255/255]; [153/255, 0/255, 0/255]; [0/255, 0/255, 102/255]; [51/255, 102/255, 0/255]; [255/255, 0/255, 0/255]; [204/255, 204/255, 51/255]; [1/255, 150/255, 255/255]};
    kidRGBVals = {[90/255, 21/255, 71/255]; [146/255, 5/255, 61/255]; [255/255, 174/255, 8/255]}% [107/255, 116/255, 0/255]; [14/255, 90/255, 46/255]}; %[0/255, 129/255, 111/255]; [183/255, 96/255, 85/255]; [74/255, 92/255, 163/255]; [102/255, 255/255, 0/255]; [255/255, 113/255, 95/255]; [255/255, 255/255, 0/255]; [161/255, 226/255, 255/255]; [183/255, 96/255, 85/255]; [74/255, 92/255, 163/255]; [102/255, 255/255, 0/255]; [255/255, 113/255, 95/255]; [255/255, 255/255, 0/255]; [161/255, 226/255, 255/255]};
    % adultRGBVals = {[255/255, 45/255, 89/255]; [254/255, 90/255, 64/255]; [233/255, 201/255, 104/255]; [253/255, 166/255, 14/255]; [247/255, 184/255, 8/255]; [52/255, 79/255, 66/255]; [88/255, 129/255, 89/255]; [162/255, 177/255, 138/255]};
    % kidRGBVals = {[255/255, 116/255, 140/255]; [255/255, 138/255, 119/255]; [255/255, 220/255, 85/255]; [253/255, 191/255, 102/255]; [249/255, 207/255, 109/255]; [107/255, 127/255, 117/255]; [123/255, 154/255, 123/255];[194/255, 205/255, 180/255]};

    % Create containers.Map for ROI colors
    roiColors = containers.Map(roiNames, cellfun(@(x,y) [x;y], adultRGBVals, kidRGBVals, 'UniformOutput', false));

    % Get color for current ROI
    colors = roiColors(roi);
    adultColor = colors(1,:);
    kidColor = colors(2,:);

    mAdults = adults.slope;
    intAdults = adults.intercept;
    mKids = kids.slope;
    intKids = kids.intercept;

    mAdults(isnan(mAdults)) = [];
    intAdults(isnan(intAdults)) = [];
    mKids(isnan(mKids)) = [];
    intKids(isnan(intKids)) = [];

    mMeanAdults = mean(mAdults);
    intMeanAdults = mean(intAdults);
    mMeanKids = mean(mKids);
    intMeanKids = mean(intKids);
    % 
    % mSTEAdults = std(mAdults) / sqrt(length(mAdults));
    % intSTEAdults = std(intAdults) / sqrt(length(intAdults));
    % mSTEKids = std(mKids) / sqrt(length(mKids));
    % intSTEKids = std(intKids) / sqrt(length(intKids));

    % Calculate standard deviation for slopes and intercepts
    mSDAdults = std(mAdults);
    intSDAdults = std(intAdults);
    mSDKids = std(mKids);
    intSDKids = std(intKids);

    % yPointsAdults = (mMeanAdults .* xPoints) + intMeanAdults;
    % yPointsKids = (mMeanKids .* xPoints) + intMeanKids;
    % UpperSlopeAdults = mMeanAdults + mSTEAdults;
    % LowerSlopeAdults = mMeanAdults - mSTEAdults;
    % UpperSlopeKids = mMeanKids + mSTEKids;
    % LowerSlopeKids = mMeanKids - mSTEKids;

    % Calculate upper and lower bounds for confidence intervals using SD
    yPointsAdults = (mMeanAdults .* xPoints) + intMeanAdults;
    yPointsKids = (mMeanKids .* xPoints) + intMeanKids;
    UpperSlopeAdults = mMeanAdults + mSDAdults;
    LowerSlopeAdults = mMeanAdults - mSDAdults;
    UpperSlopeKids = mMeanKids + mSDKids;
    LowerSlopeKids = mMeanKids - mSDKids;

    yPointsUpperAdults = (UpperSlopeAdults .* xPoints) + intMeanAdults;
    yPointsLowerAdults = (LowerSlopeAdults .* xPoints) + intMeanAdults;
    yPointsUpperKids = (UpperSlopeKids .* xPoints) + intMeanKids;
    yPointsLowerKids = (LowerSlopeKids .* xPoints) + intMeanKids;

    % Plot confidence intervals for adults and kids
    patch([xPoints, fliplr(xPoints)], [yPointsUpperAdults, fliplr(yPointsLowerAdults)], adultColor, 'FaceAlpha', 0.2, 'EdgeAlpha', 0);
    hold on;
    patch([xPoints, fliplr(xPoints)], [yPointsUpperKids, fliplr(yPointsLowerKids)], kidColor, 'FaceAlpha', 0.2, 'EdgeAlpha', 0);
    hold on;

    % Plot lines for adults and kids
    plot(xPoints, yPointsAdults, 'Color', adultColor, 'LineWidth', 4);
    plot(xPoints, yPointsKids, 'Color', kidColor, 'LineStyle', '--', 'LineWidth', 2);

    % Add labels and title
    xlabel('Eccentricity (dva)', 'fontsize', 35, 'FontName', 'Avenir');
    ylabel('pRF size (dva)', 'fontsize', 35, 'FontName', 'Avenir');
    %title(roi, 'fontsize', 18);
    set(gca, 'fontsize', 30);
    axis square;
    xlim([0, 20]);
    ylim([0, 20]);
    xticks(0:5:20);
    yticks(0:5:20);

end


function savePlot()
    saveDir = fullfile(pwd, 'output');
    if ~exist(saveDir, 'dir')
        mkdir(saveDir);
    end
end
