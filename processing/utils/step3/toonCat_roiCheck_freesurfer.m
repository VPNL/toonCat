function toonCat_roiCheck_freesurfer(fsDir, resultsPath, subjects, hemi, group, toonCatROIs, atlas)

% This script checks for the roi labels in the freesurfer directories so we
% can see which ones we have and which ones we don't per subject


% Create a cell array to store the table data
tableData = cell(length(subjects), 1 + numel(toonCatROIs) * numel(hemi));

% Iterate through subjects
for i = 1:length(subjects)
    tableData{i, 1} = subjects{i};
    
    % Iterate through hemispheres and ROIs
    for j = 1:numel(toonCatROIs)
        for h = 1:numel(hemi)
            file_name = sprintf('%s.%s_%s', hemi{h}, toonCatROIs{j}, atlas); 
            %file_name = sprintf('%s.%s', hemi{h}, toonCatROIs{j});
            file_path = fullfile(fsDir, subjects{i}, 'label', [file_name, '.label']); 

            % Check if the file exists and populate table cell accordingly
            if exist(file_path, 'file')
                tableData{i, (j-1)*numel(hemi) + h + 1} = 'Y';
            else
                tableData{i, (j-1)*numel(hemi) + h + 1} = 'N';
            end
        end
    end
end

% Create column names for the table
columnNames = [{'Subject'}];
for j = 1:numel(toonCatROIs)
    for h = 1:numel(hemi)
        columnNames{end+1} = sprintf('%s.%s', hemi{h}, toonCatROIs{j});
    end
end
resultTable = cell2table(tableData, 'VariableNames', columnNames);

% Save the table to a CSV file
tableName = ['roi_table_freesurfer_', group, '_', atlas, '.csv'];
writetable( resultTable, fullfile(resultsPath, tableName), 'Delimiter', ',');

disp(['Table saved to ' tableName]);
