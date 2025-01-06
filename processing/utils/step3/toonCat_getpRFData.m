function toonCat_getpRFData(sessions,hemis,group,exptDir,exptName,atlas,ROIs)
% Gather all pRF model data to mimic Sonia's pRFsets plotting code
% This also stores all the data on individual voxel pRFs centers
%
%   sessions: list of subs/sessions
%   hemis: lh, rh
%   group: add this for file names since we also work with adults, teens,
%   kids separately
%   exptDir: where the subjects live/the parent folder of where you want
%   your results saved out
%   atlas: toon or wang labels
%
%
% Updated 10/2019 by DF
% Adapted -> function 8/2023 by JKY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Setup
% Directories
sessionDir = [exptDir 'data'];
dataDir = [exptDir 'results/jewelia'];
figDir = [exptDir 'results/jewelia'];

% Parameters
ve_cutoff = .20;
fieldRange = 20;
fieldRange2plot = 20;
norm = 0;
sigThresh = 0.21; % size threshold
eThresh = [0 fieldRange];
voxThresh = 10; % minimum number of voxels per ROI

% mrVista Parameters
dt =  'Averages'; scan=1; % set data type and scan
prfModel =  'retModel-cssFit-fFit.mat'; % set pRF model
cothresh=0.2; % set cothresh (variance explained) for thresholding pRF model
retROISuffix = ['_' atlas '.mat'];

%% Loop through hemis and calc centers
for h = 1:length(hemis)

    %% Calculate map variables (center, size, eccentricity, variance, sigma)

    maps={};

    for r = 1:length(ROIs)
        maps = horzcat(maps,{[hemis{h} '.' ROIs{r} retROISuffix]});
    end
   
    clear info subj
    
    %% Set up the pRF sets format

    % 1. info struct
    info.subjs = sessions;
    info.expt = 'toon';
    info.minR2 = ve_cutoff*100;
    info.ROIs = maps;
    info.hemis = hemis;
    % not sure if these are necc...
    info.task = '';
    info.whichStim = 'sweep';
    info.whichModel ='kayCSS';
    info.setNotes = '';
    info.fitSuffix = ''; 

    for i = 1:length(sessions)

       cd(fullfile(sessionDir,sessions{i}))

       % Initialize Toon Session w/ ROIs
       vw = toon_initRM(prfModel, {}, cothresh, dt, scan);


        for m = 1:length(maps) % if sub has map, put pRF_cov into data, otherwise fill with NaNs

            clear RFcov coIndices figHandle all_models weight data; 

            subj(i).roi(m).fits.session = sessions{i};
            subj(i).roi(m).fits.ROIname = maps{m};
            
            if exist(fullfile(sessionDir, sessions{i}, '3DAnatomy', 'ROIs', maps{m})) || exist(fullfile(sessionDir, sessions{i}, '3Danatomy', 'ROIs', maps{m}))
                vw = loadROI(vw,maps{m});
                %vw=viewSet(vw,'selectedroi',m);

                    % Set coverage parameters
                    method='max'; %method: of computing coverage. I usually use 'sum' or 'max'
                    cothresh=0.2; %cothresh:        threshold by variance explained in model
                    nboot=50;    %  number of bootstraps; default is 50
                    prf_size=1; %     0 = plot pRF center; 1 = use pRF size
    
                    [RFcov, coIndices, figHandle, all_models, weight, data] = toon_rmPlotCoverage(vw,'method',method,'cothresh',cothresh,'nboot',nboot,'prf_size',prf_size,'fieldrange', fieldRange2plot);% 'weight',weight

                if ~isempty(data) %only if there are above threshold voxels
                    if length(data.subSize1) < voxThresh %and more of them than our set threshold
                        subj(i).roi(m).fits(1).vox(1).size = NaN; %prf size for that voxel
                        subj(i).roi(m).fits(1).vox(1).sigma = NaN;
                        subj(i).roi(m).fits(1).vox(1).XYdeg = NaN; %prf center
                        subj(i).roi(m).fits(1).vox(1).eccen = NaN; % eccentricity
                        subj(i).roi(m).fits(1).vox(1).r2 = NaN; % variance explained
                        subj(i).roi(m).fits(1).vox(1).ph = NaN % polar angle/phase
                        subj(i).roi(m).fits(1).vox(1).X = NaN; % pRF centerX
                        subj(i).roi(m).fits(1).vox(1).Y = NaN % pRF centeY

                    else
                        for v = 1:length(data.subSize1)
                            if data.subSize1(v) > sigThresh
                                subj(i).roi(m).fits(1).vox(v).size = data.subSigSize(v); %prf size for that voxel - already takes into account diving by sqrt(expt) in rmGet.m
                                subj(i).roi(m).fits(1).vox(v).sigma = data.subSize1(v); %this one is actually just sigma
                                subj(i).roi(m).fits(1).vox(v).XYdeg = [data.subx0(v), data.suby0(v)]; %prf center
                                subj(i).roi(m).fits(1).vox(v).eccen = data.subEcc(v); % eccentricity
                                subj(i).roi(m).fits(1).vox(v).r2 = data.subCo(v); % variance explained
                                subj(i).roi(m).fits(1).vox(v).ph = data.subPh(v); % polar angle/phase
                                subj(i).roi(m).fits(1).vox(v).X = data.subx0(v); % pRF centerX
                                subj(i).roi(m).fits(1).vox(v).Y = data.suby0(v); % pRF centeY                           
                            else
                                subj(i).roi(m).fits(1).vox(v).size = NaN;
                                subj(i).roi(m).fits(1).vox(v).sigma = NaN;
                                subj(i).roi(m).fits(1).vox(v).XYdeg = NaN;
                                subj(i).roi(m).fits(1).vox(v).eccen = NaN;
                                subj(i).roi(m).fits(1).vox(v).r2 = NaN;
                                subj(i).roi(m).fits(1).vox(v).ph = NaN;
                                subj(i).roi(m).fits(1).vox(v).X = NaN; % pRF centerX
                                subj(i).roi(m).fits(1).vox(v).Y = NaN % pRF centeY
                            end
                        end

                        % Some errors with subjects whose voxels all fall
                        % outside of a threshold; the code below edits the
                        % structure so that it doesn't give a number of
                        % voxels
                    

                        % Create a new struct with the same fields, initialized with NaN
                        new_vox = struct('size', NaN, 'sigma', NaN, 'XYdeg', NaN, 'eccen', NaN, 'r2', NaN, 'ph', NaN, 'X', NaN, 'Y', NaN);

                        % Iterate over each field
                        fields_to_check = fieldnames(new_vox);
                        for field = fields_to_check'
                            fieldName = field{1};
                            fieldData = [subj(i).roi(m).fits(1).vox.(fieldName)];

                            % Check if all values in the field are NaN
                            if all(isnan(fieldData))
                                % If all are NaN, assign NaN to the corresponding field in new_vox
                                new_vox.(fieldName) = NaN;
                                % Now replace the original subj(i).roi(m).fits(1).vox with the new_vox
                                subj(i).roi(m).fits(1).vox = new_vox;
                            elseif any(isnan(fieldData),2)
                                % remove NaN rows
                                fieldData(any(isnan(fieldData),2), :) = []
                            end
                        end

                        % If not all are NaN, find 'rows' where the field is not NaN and keep them
                        notNaNIdx = ~isnan([subj(i).roi(m).fits(1).vox.eccen]);
                        % Directly filter the 'rows' with NaN in the current field
                        subj(i).roi(m).fits(1).vox = subj(i).roi(m).fits(1).vox(notNaNIdx);

                        if length(subj(i).roi(m).fits.vox) < voxThresh %and more of them than our set threshold
                            subj(i).roi(m).fits(1).vox(1).size = NaN; %prf size for that voxel
                            subj(i).roi(m).fits(1).vox(1).sigma = NaN;
                            subj(i).roi(m).fits(1).vox(1).XYdeg = NaN; %prf center
                            subj(i).roi(m).fits(1).vox(1).eccen = NaN; % eccentricity
                            subj(i).roi(m).fits(1).vox(1).r2 = NaN; % variance explained
                            subj(i).roi(m).fits(1).vox(1).ph = NaN % polar angle/phase
                            subj(i).roi(m).fits(1).vox(1).X = NaN; % pRF centerX
                            subj(i).roi(m).fits(1).vox(1).Y = NaN % pRF centerY
                        end

                    end
                else
                    subj(i).roi(m).fits(1).vox(1).size = NaN; %prf size for that voxel
                    subj(i).roi(m).fits(1).vox(1).sigma = NaN;
                    subj(i).roi(m).fits(1).vox(1).XYdeg = NaN; %prf center
                    subj(i).roi(m).fits(1).vox(1).eccen = NaN; % eccentricity
                    subj(i).roi(m).fits(1).vox(1).r2 = NaN; % variance explained
                    subj(i).roi(m).fits(1).vox(1).ph = NaN; % polar angle/phase
                    subj(i).roi(m).fits(1).vox(1).X = NaN; % pRF centerX
                    subj(i).roi(m).fits(1).vox(1).Y = NaN % pRF centeY
                end    

            else
                subj(i).roi(m).fits(1).vox(1).size = NaN; %prf size for that voxel
                subj(i).roi(m).fits(1).vox(1).sigma = NaN;
                subj(i).roi(m).fits(1).vox(1).XYdeg = NaN; %prf center
                subj(i).roi(m).fits(1).vox(1).eccen = NaN; % eccentricity
                subj(i).roi(m).fits(1).vox(1).r2 = NaN; % variance explained
                subj(i).roi(m).fits(1).vox(1).ph = NaN; % polar angle/phase
                subj(i).roi(m).fits(1).vox(1).X = NaN; % pRF centerX
                subj(i).roi(m).fits(1).vox(1).Y = NaN % pRF centeY
            end
        end

        mrvCleanWorkspace; 
        close all
    end

    % Save file out
    saveFile = fullfile(dataDir,[hemis{h} '.pRFset_' num2str(fieldRange) '_ve' num2str(ve_cutoff*100) '_voxthresh' num2str(voxThresh) '_plotRange' num2str(fieldRange2plot) '_' exptName '_' group '_' atlas 'ROIs.mat']); 
    save(saveFile,'info', 'subj');
end

close all