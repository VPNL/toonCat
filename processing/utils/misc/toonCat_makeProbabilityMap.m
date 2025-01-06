% toonCat_makeProbabilityMap.m

% This file makes a probability map of all the subjects and then
% thresholds it by a certain percentage

%% Make probability map (unthresholded)
% Define the directory containing the .label files
subDir = '/oak/stanford/groups/kalanit/biac2/kgs/anatomy/freesurferRecon/Kids_AcrossYears';
setenv("SUBJECTS_DIR", subDir);
labelDir = '/oak/stanford/groups/kalanit/biac2/kgs/anatomy/freesurferRecon/Kids_AcrossYears/fsaverage/label/toonCat/adults_MTG_rh';  % Path to the directory with .label files
outputDir = '/oak/stanford/groups/kalanit/biac2/kgs/anatomy/freesurferRecon/Kids_AcrossYears/fsaverage/label/toonCat';      % Output directory for the final probabilistic map
hemi = 'rh';  
label = [hemi '.MTG_limbs_fsaverage_adults'];


% Get a list of all .label files in the directory
labelFiles = dir(fullfile(labelDir, '*.label'));
subjectCount = length(labelFiles);

% Initialize the sum of labels (as binary) on fsaverage surface
sumFile = fullfile(outputDir, [label,'_probMap.mgz']);
concatCmd = 'mri_concat ';

% Loop through each .label file and convert it to binary mask in .mgz format
for i = 1:subjectCount
    labelFile = fullfile(labelDir, labelFiles(i).name);

    % Convert label to binary mask 
    VolMaskFile = fullfile(outputDir, [labelFiles(i).name(1:end-6), '.mgz']);
    binaryMaskFile = fullfile(outputDir, [labelFiles(i).name(1:end-6), '_binary.mgz']);
    
    cmd = sprintf('mri_label2vol --label %s --temp ./mri/orig.mgz --identity --subject fsaverage --hemi %s --o %s', labelFile, hemi, VolMaskFile);
    system(cmd);  
    cmd = sprintf('mri_vol2surf --src %s --srcreg ./surf/register.dat --hemi %s --o %s', VolMaskFile, hemi, binaryMaskFile);
    system(cmd);  
    
    % Append each individual binary mask to the concatenation command
    concatCmd = [concatCmd, '--i ', binaryMaskFile, ' '];
end

% Does this intersect with other ROIs? (Mostly the MTG?)

% Finalize the concatenation command to calculate the mean across all
% subjects
concatCmd = [concatCmd, '--o ', sumFile, ' --mean'];
system(concatCmd);  % Execute the concatenation and mean calculation

%% Threshold the probabilistic map and project to individuals
% Thresholding each .mgz file in Freeview (we chose 0.13 based on the
% data), draw a label around for each ROI. Then project them back to the
% individual space.


% SETUP: Project probabilistic map back to the native space
% 0.Pathing
share_prefix = '/share/kalanit';
oak_prefix = '/oak/stanford/groups';

% 0.Toolboxes
addpath(genpath('/share/kalanit/software/vistasoft/')); 
addpath(genpath(fullfile(oak_prefix, 'kalanit/biac2/kgs/projects/Kids_AcrossYears/FMRI/Toonotopy/code/')));

% 1.Subjects
% Initialize the sessionLists.
sessionLists_vista_FS;

% Directory
exptDir = fullfile(oak_prefix,'kalanit/biac2/kgs/projects/Kids_AcrossYears/FMRI/Localizer/data_toonCat');

%% Convert labels to native space
% Select ROIs
hemis = {'rh','lh'};
labels = {'pSTS_faces_adultAvg_probMap_toonCat'}; %, 'MTG_limbs_adultAvg_probMap_toonCat'

% Select subjects
subjects = sessions.fsAll;

for s = 1:length(subjects)
    for h = 1:length(hemis)
        for l = 1:length(labels)
            
            cd(fullfile(subDir, 'fsaverage', 'label'));
        
            unix(['mri_label2label --srcsubject fsaverage' ...
                ' --srclabel ' hemis{h} '.' labels{l} '.label'...
                ' --trgsubject ' subjects{s} ...
                ' --trglabel ' hemis{h} '.' labels{l} '.label'...
                ' --hemi ' hemis{h} ...
                ' --regmethod surface']);
        end
    end
end

disp('Surface-based probabilistic map creation complete.');
