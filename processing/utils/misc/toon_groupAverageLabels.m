function toon_groupAverageLabels(subDir, subjects, group, hemi, label, surface)
%
% This function averages labels for all subjects in a
% group and visualizes it on an average surface in Freesurfer.
% Labels must be drawn first:)
%\
%   subDir: directory for maps (freesurfer directory)
%   subjects: list of subjects as array or txt file
%   group: name of age group
%   hemi: rh or lh
%   map: retinotopic map to average
%   surface: surface to align maps to (fsaverage, Haxby)
%
% JKY 08/2023
%
%% Setup
setenv('SUBJECTS_DIR', subDir);
cd(subDir);

labelName = [hemi, '.',label];
outputLabelStem = [labelName, '_', group];
labelHome = fullfile(subDir, surface, 'label', 'toonCat/adults_lh');

%% Convert individual labels from native space to average space
for s = 1:length(subjects)

    % outputLabelName = [labelName, '_', group, '_', subjects{s}];
    % cd(fullfile(subDir, subjects{s}, 'label'));
    cd(fullfile(subDir, 'fsaverage', 'label/toonCat'));
    % % Convert map
    % unix(['mri_label2label --srcsubject ' subjects{s} ...
    %     ' --srclabel ' labelName '.label'...
    %     ' --trgsubject ' surface ...
    %     ' --trglabel ' outputLabelName '.label'...
    %     ' --hemi ' hemi ...
    %     ' --regmethod surface']);
    labelName = 'rh.MTG_limbs_adults_avg';
    hemi = 'rh'
    unix(['mri_label2label --srcsubject fsaverage' ...
        ' --srclabel ' labelName '.label'...
        ' --trgsubject ' subjects{s} ...
        ' --trglabel ' labelName '.label'...
        ' --hemi ' hemi ...
        ' --regmethod surface']);

    
    % Move map to one place
   % unix(['mv ' outputLabelStem '*.label ' labelHome])

end

%% Average labels across subjects
% cd(fullfile(subDir, surface, 'label'));
% unix('mv *pSTS_faces_toon_JC_adults* toonCat/');

cd(labelHome);

unix(['mri_mergelabels -i ' outputLabelStem '.label'...
    ' -o ' outputLabelStem '_avg.label']);

unix('mri_mergelabels -d adults_pSTS_rh -o rh.pSTS_faces_adults_avg.label')