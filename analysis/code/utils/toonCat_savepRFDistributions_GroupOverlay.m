function toonCat_savepRFDistributions_GroupOverlay(pRFsetFile_KidsTeens, pRFsetFile_Adults, measure)
% Save PNGs of pRF distributions per ROI with Adolescents and Adults overlaid
%
% pRFsetFile_KidsTeens: path to KidsTeens pRFset file
% pRFsetFile_Adults: path to Adults pRFset file
% measure: 'X', 'Y', 'eccen', or 'size'

%% Set ranges and bins for each measure
switch measure
    case 'X'
        range = [-10, 10];
    case 'Y'
        range = [-6, 6];
    case 'eccen'
        range = [0, 15];
    case 'size'
        range = [0, 20];
    otherwise
        error('Unknown measure: %s', measure)
end
binEdges = linspace(range(1), range(2), 11); % 10 bins
binCenters = binEdges(1:end-1) + diff(binEdges)/2;

%% Load Data
KidsTeens_data = loadGroupData(pRFsetFile_KidsTeens, measure, binEdges);
Adults_data = loadGroupData(pRFsetFile_Adults, measure, binEdges);
nROIs = length(KidsTeens_data.ROIs);

%% For each ROI: make plot
for r = 1:nROIs
    figure('Color', 'w', 'Position', [100 100 800 600]);

    % Get colors
    [lightColor, darkColor] = getGroupColors(KidsTeens_data.ROIs{r});

    % Plot Adolescents (lighter color)
    hold on
    plotShaded(KidsTeens_data.meanPercent(r,:), KidsTeens_data.semPercent(r,:), ...
        binCenters, lightColor, darkColor, '--','Adolescents');

    % Plot Adults (darker color)
    plotShaded(Adults_data.meanPercent(r,:), Adults_data.semPercent(r,:), ...
        binCenters, lightColor * 0.7, darkColor * 0.7, '-','Adults');

    % Add vertical line at 0 for X or Y measures
    if ismember(measure, {'X', 'Y'})
        xline(0, 'Color', [0.5 0.5 0.5], 'LineStyle', '-', 'LineWidth', 2);
    end

    % Formatting
    xlabel(sprintf('%s (deg)', measure))
    ylabel('% of Voxels')
    ylim([0 40])
    yticks(0:10:40)
    set(gca, 'FontSize', 35)
    grid off
    box off
    %legend('show', 'Location', 'best')

    % Save
    outDir = fullfile(fileparts(pRFsetFile_KidsTeens), 'group_overlay_distributions', measure);
    if ~exist(outDir, 'dir'); mkdir(outDir); end
    outName = fullfile(outDir, sprintf('%s_%s_distribution_overlay.png', ...
        measure, strrep(KidsTeens_data.ROIs{r}, '.', '_')));
    print(gcf, outName, '-dpng', '-r300');
    fprintf('Saved: %s\n', outName)
    close(gcf)
end
end

function plotShaded(meanLine, semLine, x, fillColor, lineColor, lineStyle, label)
    % Plot shaded SEM area
    fillAreaY = [meanLine + semLine, fliplr(meanLine - semLine)];
    fillAreaX = [x, fliplr(x)];
    fill(fillAreaX, fillAreaY, fillColor, ...
        'FaceAlpha', 0.3, 'EdgeColor', 'none')

    % Plot mean line
    plot(x, meanLine, lineStyle, 'Color', lineColor, 'LineWidth', 3, 'DisplayName', label)
end

function [lightColor, darkColor] = getGroupColors(roiName)
    roiNameLower = lower(roiName);
    if contains(roiNameLower, 'face')
        lightColor = [1 0.6 0.6]; % light red
        darkColor  = [0.8 0 0];   % dark red
    elseif contains(roiNameLower, 'word')
        lightColor = [0.6 0.6 1]; % light blue
        darkColor  = [0 0 0.8];   % dark blue
    elseif contains(roiNameLower, 'bodies') || contains(roiNameLower, 'limb')
        lightColor = [1 0.9 0.6]; % light yellow
        darkColor  = [0.8 0.6 0]; % dark yellow
    elseif contains(roiNameLower, 'place') || contains(roiNameLower, 'scene')
        lightColor = [0.6 1 0.6]; % light green
        darkColor  = [0 0.6 0];   % dark green
    else
        lightColor = [0.8 0.8 0.8]; % gray
        darkColor  = [0.4 0.4 0.4]; % dark gray
    end
end

%% Helper: Load group data and bin
function data = loadGroupData(pRFsetFile, measure, binEdges)
    load(pRFsetFile, 'subj', 'info');
    nSubs = length(subj);
    nROIs = length(info.ROIs);
    nBins = length(binEdges)-1;

    percentInBins = NaN(nSubs, nROIs, nBins);

    for s = 1:nSubs
        for r = 1:nROIs
            vox = subj(s).roi(r).fits.vox;
            if isempty(vox) || all(isnan([vox.(measure)]))
                continue
            end
            values = [vox.(measure)];
            counts = histcounts(values, binEdges);
            percentInBins(s,r,:) = (counts / sum(counts)) * 100;
        end
    end

    % Store in struct
    data.percentInBins = percentInBins;
    data.meanPercent = squeeze(mean(percentInBins,1,'omitnan'));

    % Get std across subjects
    stdPercent = squeeze(std(percentInBins, [], 1, 'omitnan')); % [nROIs x nBins]

    % Count number of subjects per bin
    nSubjPerBin = squeeze(sum(~isnan(percentInBins), 1));       % [nROIs x nBins]

    % Compute SEM safely (avoid divide by zero)
    semPercent = stdPercent ./ sqrt(nSubjPerBin);
    semPercent(nSubjPerBin == 0) = NaN; % set SEM to NaN where no subjects

    data.semPercent = semPercent;
    data.ROIs = info.ROIs;
end

