function toonCat_savepRFDistributions_byStream(dataDir, hemi, measure)
% Save PNGs of pRF distributions per stream (overlay plots in one row)
% Each stream gets 7 equally-sized subplots, even if some are blank

%% Define ROIs
streamROIs.ventral = {'pOTS_words_toon','mOTS_words_toon','OTS_bodies_toon','IOG_faces_toon_JC','pFus_faces_toon','mFus_faces_toon','CoS_places_toon'};
streamROIs.lateral = {'LOS_limbs_toon_JC','ITG_limbs_toon_JC','MTG_limbs_adultAvg_probMap_toonCat','pSTS_faces_adultAvg_probMap_toonCat'};
streamROIs.dorsal  = {'MOG_places_toon_JC','IPS_places_toon_JC'};

roiToAtlas = containers.Map();
roiToAtlas('IOG_faces_toon_JC') = 'toon_JC';
roiToAtlas('pFus_faces_toon') = 'toon';
roiToAtlas('mFus_faces_toon') = 'toon';
roiToAtlas('OTS_bodies_toon') = 'toon';
roiToAtlas('pOTS_words_toon') = 'toon';
roiToAtlas('mOTS_words_toon') = 'toon';
roiToAtlas('CoS_places_toon') = 'toon';
roiToAtlas('pSTS_faces_adultAvg_probMap_toonCat') = 'adultAvg_probMap_toonCat';
roiToAtlas('LOS_limbs_toon_JC') = 'toon_JC';
roiToAtlas('ITG_limbs_toon_JC') = 'toon_JC';
roiToAtlas('MTG_limbs_adultAvg_probMap_toonCat') = 'adultAvg_probMap_toonCat';
roiToAtlas('IPS_places_toon_JC') = 'toon_JC';
roiToAtlas('MOG_places_toon_JC') = 'toon_JC';

switch measure
    case 'X', range = [-15, 15];
    case 'Y', range = [-6, 6];
    case 'eccen', range = [0, 15];
    case 'size', range = [0, 20];
    otherwise, error('Unknown measure: %s', measure);
end

binEdges = linspace(range(1), range(2), 11);
binCenters = binEdges(1:end-1) + diff(binEdges)/2;

%% Load atlas data
atlasData = containers.Map();
atlases = {'toon', 'toon_JC', 'adultAvg_probMap_toonCat'};

for i = 1:length(atlases)
    kidsFile = fullfile(dataDir, sprintf('%s.pRFset_20_ve20_voxthresh10_plotRange20_toonCat_KidsTeens_%sROIs.mat', hemi, atlases{i}));
    adultsFile = fullfile(dataDir, sprintf('%s.pRFset_20_ve20_voxthresh10_plotRange20_toonCat_Adults_%sROIs.mat', hemi, atlases{i}));

    if exist(kidsFile, 'file') && exist(adultsFile, 'file')
        kids = loadGroupData(kidsFile, measure, binEdges);
        adults = loadGroupData(adultsFile, measure, binEdges);
        atlasData(atlases{i}) = struct('kids', kids, 'adults', adults);
        fprintf('Loaded atlas %s\n', atlases{i});
    else
        fprintf('Skipping atlas %s (missing files)\n', atlases{i});
    end
end

%% Plot per stream
streamNames = fieldnames(streamROIs);

for s = 1:length(streamNames)
    streamName = streamNames{s};
    roiList = streamROIs.(streamName);

    validROIs = {};
    roiDataSources = {};

    for i = 1:length(roiList)
        roi = roiList{i};
        atlas = roiToAtlas(roi);
        if isKey(atlasData, atlas)
            data = atlasData(atlas);
            storedNames = cellfun(@(x) regexprep(regexprep(x, '^[lr]h\.', ''), '\.mat$', ''), data.kids.ROIs, 'UniformOutput', false);
            idx = find(strcmp(storedNames, roi));
            if ~isempty(idx)
                validROIs{end+1} = roi;
                roiDataSources{end+1} = struct('atlas', atlas, 'idx', idx(1));
            end
        end
    end

    nROIs = length(validROIs);
    nCols = 7;

    fig = figure('Visible', 'off','Color', 'w', 'Units', 'pixels', 'Position', [100, 100, 1200, 200]);

    for p = 1:nCols
        axLeft = 75 + (p - 1) * 160;
        axBottom = 80;
        axWidth = 130;
        axHeight = 100;

        ax = axes('Units', 'pixels', 'Position', [axLeft, axBottom, axWidth, axHeight]); hold(ax, 'on');

        if p > nROIs
            axis off;
            continue;
        end

        roiName = validROIs{p};
        source = roiDataSources{p};
        data = atlasData(source.atlas);
        r = source.idx;

        [lightColor, darkColor] = getGroupColors(data.kids.ROIs{r});
        plotShaded(data.kids.meanPercent(r,:), data.kids.semPercent(r,:), binCenters, lightColor, darkColor, '--', 'Adolescents');
        plotShaded(data.adults.meanPercent(r,:), data.adults.semPercent(r,:), binCenters, lightColor * 0.7, darkColor * 0.7, '-', 'Adults');

        if ismember(measure, {'X', 'Y'})
            xline(0, 'Color', [0.5 0.5 0.5], 'LineWidth', 2);
        end

        % Change x-axis label based on measure
        if strcmp(measure, 'X')
            measureName = 'X-Position';
        elseif strcmp(measure, 'Y')
            measureName = 'Y-Position';
        elseif strcmp(measure, 'eccen')
            measureName = 'Eccentricity';
        elseif strcmp(measure, 'size')
            measureName = 'Size';
        else
            measureName = measure; % fallback
        end

        xlabel(sprintf('%s (°)', measureName), 'FontSize', 24, 'FontName', 'Avenir');
        if p == 1
            ylabel('% of Voxels', 'FontSize', 24, 'FontName', 'Avenir');
        else
            set(gca, 'YColor', 'w');
        end

        ylim([0 50]); yticks(0:10:50);
        set(gca, 'FontSize', 18, 'FontName', 'Avenir', 'LineWidth', 1.5); 
        box off;

        compareGroups(data.kids, data.adults, r);
    end

    %set(gcf, 'PaperPositionMode', 'auto');
    outDir = fullfile(dataDir, 'stream_distributions', streamName);
    if ~exist(outDir, 'dir'), mkdir(outDir); end
    outPath = fullfile(outDir, sprintf('%s_%s_%s_stream_distribution.png', hemi, measure, streamName));
    print(fig, outPath, '-dpng', '-r300');
    close(fig);
    fprintf('Saved: %s\n', outPath);
end
end

function plotShaded(meanLine, semLine, x, fillColor, lineColor, lineStyle, label)
    fill([x fliplr(x)], [meanLine + semLine, fliplr(meanLine - semLine)], ...
        fillColor, 'FaceAlpha', 0.3, 'EdgeColor', 'none');
    plot(x, meanLine, lineStyle, 'Color', lineColor, 'LineWidth', 2, 'DisplayName', label);
end

function [lightColor, darkColor] = getGroupColors(roiName)
    roiName = lower(roiName);
    if contains(roiName, 'face')
        lightColor = [1 0.6 0.6]; darkColor = [0.8 0 0];
    elseif contains(roiName, 'word')
        lightColor = [0.6 0.6 1]; darkColor = [0 0 0.8];
    elseif contains(roiName, 'bodies') || contains(roiName, 'limb')
        lightColor = [1 0.9 0.6]; darkColor = [0.8 0.6 0];
    elseif contains(roiName, 'place') || contains(roiName, 'scene')
        lightColor = [0.6 1 0.6]; darkColor = [0 0.6 0];
    else
        lightColor = [0.8 0.8 0.8]; darkColor = [0.4 0.4 0.4];
    end
end

function data = loadGroupData(pRFsetFile, measure, binEdges)
    load(pRFsetFile, 'subj', 'info');
    nSubs = length(subj);
    nROIs = length(info.ROIs);
    nBins = length(binEdges) - 1;
    percentInBins = NaN(nSubs, nROIs, nBins);
    for s = 1:nSubs
        for r = 1:nROIs
            vox = subj(s).roi(r).fits.vox;
            if isempty(vox) || all(isnan([vox.(measure)])), continue; end
            values = [vox.(measure)];
            counts = histcounts(values, binEdges);
            percentInBins(s,r,:) = (counts / sum(counts)) * 100;
        end
    end
    data.percentInBins = percentInBins;
    data.meanPercent = squeeze(mean(percentInBins,1,'omitnan'));
    stdPercent = squeeze(std(percentInBins, [], 1, 'omitnan'));
    nSubjPerBin = squeeze(sum(~isnan(percentInBins), 1));
    data.semPercent = stdPercent ./ sqrt(nSubjPerBin);
    data.semPercent(nSubjPerBin == 0) = NaN;
    data.ROIs = info.ROIs;
end

function pVal = compareGroups(K, A, r, nPerms)
    if nargin < 4, nPerms = 10000; end
    k = squeeze(K.percentInBins(:,r,:)); k(any(isnan(k),2),:) = [];
    a = squeeze(A.percentInBins(:,r,:)); a(any(isnan(a),2),:) = [];
    if isempty(k) || isempty(a), pVal = 1; return; end
    obs = sum(abs(mean(k,1) - mean(a,1)));
    all = [k; a]; nK = size(k,1); n = size(all,1);
    null = zeros(nPerms,1);
    for i = 1:nPerms
        idx = randperm(n);
        null(i) = sum(abs(mean(all(idx(1:nK),:),1) - mean(all(idx(nK+1:end),:),1)));
    end
    pVal = mean(null >= obs);
end

