function create_pRF_montages(dataDir, hemiList, measures, roiOrder, outDir, nCols, layoutMode)
% Create montage per hemisphere and measure, optionally grouping rows by category
%
% dataDir    : folder with PNGs (each measure in its subfolder)
% hemiList   : {'lh', 'rh'}
% measures   : {'Y', 'eccen', 'size'}
% roiOrder   : cell array of ROI base names (no hemi, no atlas)
% outDir     : folder to save montages
% nCols      : number of columns per row (max)
% layoutMode : 'byCategory' (default) or 'singleRow' (all ROIs in one row)

if nargin < 6
    nCols = 4; % default columns
end
if nargin < 7 || isempty(layoutMode)
    layoutMode = 'byCategory';
end

% Possible atlas suffixes
atlasList = {'toon', 'toon_JC', 'adultAvg_probMap_toonCat'};

% Define categories
categories = {'faces', 'words', 'bodies', 'places'};

% Assign category to each ROI
roiCategories = cellfun(@getCategory, roiOrder, 'UniformOutput', false);

for h = 1:length(hemiList)
    hemi = hemiList{h};

    for m = 1:length(measures)
        measure = measures{m};
        fprintf('Creating montage for: %s, %s\n', hemi, measure);

        % Load images for all ROIs
        imgsAll = cell(length(roiOrder), 1);
        for i = 1:length(roiOrder)
            roi = roiOrder{i};
            roiFound = false;
            for a = 1:length(atlasList)
                atlas = atlasList{a};
                fileName = sprintf('%s_%s_%s_%s_mat_distribution_overlay.png', ...
                                   measure, hemi, roi, atlas);
                filePath = fullfile(dataDir, measure, fileName);
                if exist(filePath, 'file')
                    img = imread(filePath);
                    roiFound = true;
                    break; % use first match
                end
            end
            if ~roiFound
                warning('No PNG found for %s_%s in any atlas', hemi, roi);
                img = uint8(255 * ones(600, 1200, 3)); % white placeholder
            end
            imgsAll{i} = img;
        end

        % Get max image dimensions
        sizes = cellfun(@size, imgsAll, 'UniformOutput', false);
        heights = cellfun(@(s) s(1), sizes);
        widths  = cellfun(@(s) s(2), sizes);
        maxH = max(heights);
        maxW = max(widths);

        % Pad images to max size
        for i = 1:length(imgsAll)
            img = imgsAll{i};
            [h, w, ~] = size(img);
            padH = maxH - h;
            padW = maxW - w;
            imgPadded = uint8(255 * ones(maxH, maxW, 3));
            imgPadded(1:h, 1:w, :) = img;
            imgsAll{i} = imgPadded;
        end

        % Build montage
        if strcmp(layoutMode, 'byCategory')
            rows = {};
            for c = 1:length(categories)
                cat = categories{c};
                catIndices = find(strcmp(roiCategories, cat));
                imgsCat = imgsAll(catIndices);
                nCat = length(imgsCat);
                rowImgs = [];
                for i = 1:nCat
                    rowImgs = [rowImgs, imgsCat{i}];
                end
                % Pad row if needed
                if mod(nCat, nCols) ~= 0
                    nPad = nCols - mod(nCat, nCols);
                    for p = 1:nPad
                        blank = uint8(255 * ones(maxH, maxW, 3));
                        rowImgs = [rowImgs, blank];
                    end
                end
                rows{end+1} = rowImgs;
            end
            canvas = vertcat(rows{:});

        elseif strcmp(layoutMode, 'singleRow')
            rowImgs = [];
            for i = 1:length(imgsAll)
                rowImgs = [rowImgs, imgsAll{i}];
            end
            % Pad row if needed
            if mod(length(imgsAll), nCols) ~= 0
                nPad = nCols - mod(length(imgsAll), nCols);
                for p = 1:nPad
                    blank = uint8(255 * ones(maxH, maxW, 3));
                    rowImgs = [rowImgs, blank];
                end
            end
            canvas = rowImgs;
        else
            error('Unknown layoutMode: %s', layoutMode);
        end

        % Save montage
        if ~exist(outDir, 'dir'); mkdir(outDir); end
        outFile = fullfile(outDir, ...
            sprintf('montage_%s_%s_distribution_overlay_dorsal.png', measure, hemi));
        imwrite(canvas, outFile);
        fprintf('Saved montage: %s\n', outFile);
    end
end
end

%% Helper: Assign ROI category
function cat = getCategory(roiName)
    roiNameLower = lower(roiName);
    if contains(roiNameLower, 'face')
        cat = 'faces';
    elseif contains(roiNameLower, 'word')
        cat = 'words';
    elseif contains(roiNameLower, 'bodies') || contains(roiNameLower, 'limb')
        cat = 'bodies';
    elseif contains(roiNameLower, 'place') || contains(roiNameLower, 'scene')
        cat = 'places';
    else
        cat = 'other';
    end
end
