function toon_mergeLabels(fsDir, subjects, hemi, labelPairs, atlas)

% This function merges freesurfer labels for a list of subjects. Must
% define:
%
%   fsDir: path to freesurfer directory
%   subjects: list of freesurfer sessions (use sessionLists_vista_FS)
%   hemi: list of hemis or hemi
%   label_pairs: array of paired labels to merge
%   atlas: toon or wang atlas
%
%
% JKY 2023

for s = 1:length(subjects)
    for pairIdx = 1:length(labelPairs)
        label1 = labelPairs{pairIdx}{1};
        label2 = labelPairs{pairIdx}{2};
        label_name = labelPairs{pairIdx}{3};
        
        for h = 1:length(hemi)
            cd(fullfile(fsDir, subjects{s}, 'label'))
            
            input1 = [hemi{h}, '.', label1, '_' atlas '.label'];
            input2 = [hemi{h}, '.', label2, '_' atlas '.label'];
            output_name = [hemi{h}, '.', label_name, '_' atlas '.label'];

            if exist(input1, 'file') && exist(input2, 'file')
                cmd = ['mri_mergelabels -i ' input1 ' -i ' input2 ' -o ' output_name];
                fprintf('Running: %s\n', cmd);
                system(cmd);
            elseif ~exist(input2, 'file') && exist(input1, 'file')
                cmd = ['cp ' input1 ' ' output_name];
                fprintf('Running: %s\n', cmd);
                system(cmd);
            elseif ~exist(input1, 'file') && exist(input2, 'file')
                cmd = ['cp ' input2 ' ' output_name];
                fprintf('Running: %s\n', cmd);
                system(cmd);
            else
                fprintf('No components to merge for %s\n', output_name)
            end
            

        end
    end
end
