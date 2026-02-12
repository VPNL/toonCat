% toonCat_fig2.m %
% This script creates the distribution plots and KS-testing for Figure 2
% from the toonCat paper. Requires the right and left hemisphere pRF sets
% (in data folder)
%
%
% JKY 02/2025
%% Plot group distributions
dataDir = ''
hemi = {'lh' 'rh'};
atlas = {'toon' 'toon_JC' 'adultAvg_probMap_toonCat'};
measures = {'X' 'Y' 'eccen' 'size'};

for h = 1:length(hemi)
    for a = 1:length(atlas)
        for m = 1:length(measures)
            toonCat_savepRFDistributions_GroupOverlay( ...
                fullfile(dataDir,[hemi{h} '.pRFset_20_ve20_voxthresh10_plotRange20_toonCat_KidsTeens_' atlas{a} 'ROIs.mat']), ...
                fullfile(dataDir,[hemi{h} '.pRFset_20_ve20_voxthresh10_plotRange20_toonCat_Adults_'  atlas{a} 'ROIs.mat']), ...
                measures{m});
        end
    end
end
%% Plots by stream
hemi = {'lh' 'rh'};
measures = {'X' 'Y' 'eccen' 'size'};

for h = 1:length(hemi)
    for m = 1:length(measures)
        toonCat_savepRFDistributions_byStream(dataDir, hemi{h}, measures{m});
    end
end

%% Create montages of distributions
outDir = fullfile(dataDir,'montages');
hemiList = {'lh', 'rh'};
measures = {'X', 'Y', 'eccen', 'size'};

% ventral
% ROI = {'IOG_faces', 'pFus_faces', 'mFus_faces', ...
%        'pOTS_words', 'mOTS_words','OTS_bodies',  ...
%        'CoS_places'};

% lateral
%ROI = {'pSTS_faces','LOS_limbs', 'ITG_limbs', 'MTG_limbs'};

% dorsal
%ROI = {'MOG_places', 'IPS_places'};

create_pRF_montages(dataDir, hemiList, measures, ROI, outDir, 7, 'singleRow');
