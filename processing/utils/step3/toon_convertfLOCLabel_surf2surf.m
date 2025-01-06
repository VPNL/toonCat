% This script converts category labels previously defined by Marisa/Emily
% in the same subjects affine or non-affine templates to the surfaces we
% are interested in. 

% Define sessions and years (affine)
% sessions = {
%     struct('newSess', 'AW05_scn190929_recon0920_v6', 'year', 5, 'oldSess', 'AW05avg_2345_affine'),
%     struct('newSess', 'SD06_scn181020_recon0920_v6', 'year', 3, 'oldSess', 'SD06avg_234_affine'),
%     struct('newSess', 'ENK05_scn181201_recon0920_v6', 'year', 3, 'oldSess', 'ENK05avg_23_affine'),
%     struct('newSess', 'CLC06_scn190924_recon0920_v6', 'year', 4, 'oldSess', 'CLC06avg_134_affine'),
%     struct('newSess', 'ED07_scn190824_recon0920_v6', 'year', 4, 'oldSess', 'ED07avg_14_affine'),
%     struct('newSess', 'ENK05_scn191214_recon0920_v6', 'year', 4, 'oldSess', 'ENK05avg_23_affine'),
%     struct('newSess', 'RJ09_scn181028_recon0920_v6', 'year', 3, 'oldSess', 'RJ09avg_1234_affine'),
%     struct('newSess', 'INW06_scn200112_recon0920_v6', 'year', 4, 'oldSess', 'INW06avg_1234_affine'),
%     struct('newSess', 'RJ09_scn191027_recon0920_v6', 'year', 4, 'oldSess', 'RJ09avg_1234_affine'),
%     struct('newSess', 'AOK07_scn191214_recon9020_v6', 'year', 4, 'oldSess', 'AOK07avg_1234_affine'),
%     struct('newSess', 'CS11_scn181110_recon0920_v6', 'year', 3, 'oldSess', 'CS11avg_123_affine'),
%     struct('newSess', 'GEJA09_scn200111_recon0920_v6', 'year', 4, 'oldSess', 'GEJA09avg_1234_affine'),
%     struct('newSess', 'MDT09_scn191027_recon0920_v6', 'year', 3, 'oldSess', 'MDT09avg_13_affine'),
%     struct('newSess', 'DAPA10_scn181028_recon0920_v6', 'year', 3, 'oldSess', 'DAPA10avg_123_affine'),
%     struct('newSess', 'STM10_scn191001_recon0920_v6', 'year', 3, 'oldSess', 'STM10avg_123_affine'),
%     struct('newSess', 'DAPA10_scn191123_recon0920_v6', 'year', 4, 'oldSess', 'DAPA10avg_123_affine'),
%     struct('newSess', 'CGSA11_scn191003_recon0920_v6', 'year', 4, 'oldSess', 'CGSA11avg_1234_affine'),
%     struct('newSess', 'OS12_scn190724_recon0920_v6', 'year', 6, 'oldSess', 'OS12avg_123456_affine')
% };

% Nonaffine
sessions = {
    struct('newSess', 'AW05_scn190929_recon0920_v6', 'year', '05_1', 'oldSess', 'AW05avg_34'),
    struct('newSess', 'SD06_scn181020_recon0920_v6', 'year', '03_2', 'oldSess', 'SD06avg_123'),
    struct('newSess', 'ENK05_scn181201_recon0920_v6', 'year', '03_1', 'oldSess', 'ENK05avg_23'),
    struct('newSess', 'CLC06_scn190924_recon0920_v6', 'year', '04_1', 'oldSess', 'CLC06avg_134'),
    struct('newSess', 'ED07_scn190824_recon0920_v6', 'year', '04_2', 'oldSess', 'ED07avg_14'),
    struct('newSess', 'ENK05_scn191214_recon0920_v6', 'year', '03_2', 'oldSess', 'ENK05avg_23'),
    struct('newSess', 'RJ09_scn181028_recon0920_v6', 'year', '03_2', 'oldSess', 'RJ09avg_123'),
    struct('newSess', 'INW06_scn200112_recon0920_v6', 'year', '04_1', 'oldSess', 'INW06_avg123'),
    struct('newSess', 'RJ09_scn191027_recon0920_v6', 'year', '04_1', 'oldSess', 'RJ09avg_123'),
    struct('newSess', 'AOK07_scn191214_recon9020_v6', 'year', '03_2', 'oldSess', 'AOK07_avg123'),
    struct('newSess', 'CS11_scn181110_recon0920_v6', 'year', '03_2', 'oldSess', 'CS11avg_123'),
    struct('newSess', 'GEJA09_scn200111_recon0920_v6', 'year', '04_1', 'oldSess', 'GEJA09avg_123'),
    struct('newSess', 'MDT09_scn191027_recon0920_v6', 'year', '03_2', 'oldSess', 'MDT09avg_12'),
    struct('newSess', 'DAPA10_scn181028_recon0920_v6', 'year', '03_2', 'oldSess', 'DAPA10avg_123'),
    struct('newSess', 'STM10_scn191001_recon0920_v6', 'year', '03_2', 'oldSess', 'STM10avg_12'),
    struct('newSess', 'DAPA10_scn191123_recon0920_v6', 'year', '04_1', 'oldSess', 'DAPA10avg_123'),
    struct('newSess', 'CGSA11_scn191003_recon0920_v6', 'year', '04_1', 'oldSess', 'CGSA11avg_123'),
    struct('newSess', 'OS12_scn190724_recon0920_v6', 'year', '06_1', 'oldSess', 'OS12avg_12345')
};

% Loop through each session
for i = 1:length(sessions)
    session = sessions{i};
    
    newSess = session.newSess;
    year = session.year;
    oldSess = session.oldSess;
    
    hemis = {'rh','lh'}; % List of hemispheres
    
    % Loop through each hemisphere
    for h = 1:numel(hemis)
        hemisphere = hemis{h};
        
        % Loop through each ROI label
        roi_label_patterns = {
            sprintf('%s_CoS_placehouse_%s', hemisphere, year),
            sprintf('%s_mFus_faceadultfacechild_%s', hemisphere, year),
            sprintf('%s_pFus_faceadultfacechild_%s', hemisphere, year),
            sprintf('%s_mOTS_word_%s', hemisphere, year),
            sprintf('%s_pOTS_word_%s', hemisphere, year),
            sprintf('%s_OTS_bodylimb_%s', hemisphere, year)
        };
        
        for j = 1:numel(roi_label_patterns)
            roi_label_pattern = roi_label_patterns{j};
            
            % Get the list of matching label file
            matching_files_1 = dir(fullfile('/oak/stanford/groups/kalanit/biac2/kgs/anatomy/freesurferRecon/Kids_AcrossYears', oldSess, 'label', [roi_label_pattern '.label']));
            matching_files = matching_files_1;

%             if isempty(matching_files_1)
%                 % If _1 file doesn't exist, try _2
% %                 matching_files_2 = dir(fullfile('/oak/stanford/groups/kalanit/biac2/kgs/anatomy/freesurferRecon/Kids_AcrossYears', oldSess, 'label', [roi_label_pattern '_2.label']));
% %                 matching_files = matching_files_2;
%                 disp(sprintf('Cannot find %s for subject %s', roi_label_pattern, session))
% 
%             else
%                 matching_files = matching_files_1;
%             end
            

            for k = 1:numel(matching_files)
                source_label_file = matching_files(k).name;
                source_label_path = fullfile('/oak/stanford/groups/kalanit/biac2/kgs/anatomy/freesurferRecon/Kids_AcrossYears', oldSess, 'label', source_label_file);
                
                % Extract the ROI name without the pattern, numbers, and .label extension
                [~, roi_name, ~] = fileparts(source_label_file);
                
                % Split the ROI name by underscores
                roi_name_parts = strsplit(roi_name, '_');
                
                % Ensure there are enough parts and extract the desired ones
                new_roi_name_parts = {roi_name_parts{2}, roi_name_parts{3}};

                % Create the new destination label filename
                dest_label_filename = [hemisphere '.' strjoin(new_roi_name_parts, '_') '_toon.label'];
                dest_label_path = fullfile('/oak/stanford/groups/kalanit/biac2/kgs/anatomy/freesurferRecon/Kids_AcrossYears', newSess, 'label', dest_label_filename);

                % Convert labels from subject to subject
                cmd = ['mri_label2label --srcsubject ' oldSess ...
                    ' --trgsubject ' newSess ...
                    ' --srclabel ' source_label_path ...
                    ' --trglabel ' dest_label_path ...
                    ' --regmethod surface' ...
                    ' --hemi ' hemisphere] ;
                unix(cmd);
            end

        end
    end
end
