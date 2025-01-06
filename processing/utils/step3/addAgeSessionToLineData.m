function lineDataWithAgeSession = addAgeSessionToLineData(lineData, ageFile)
    % Load age data
    ageData = readtable(ageFile, 'Delimiter', ',');

    % Initialize lineData with age and session columns
    lineDataWithAgeSession = load(lineData,'lineData');

    % Iterate over each cell in lineData
    for i = 1:numel(lineDataWithAgeSession.lineData)
        % Find the corresponding session name in the age data based on the index
        sessionName = ageData.sub{i}; % Assuming ageData.sub contains session names
        numStructs = numel(lineDataWithAgeSession.lineData{i});

        for j = 1:numStructs
            % Assign age and session information to the corresponding structure in lineData
            lineDataWithAgeSession.lineData{1,i}(j).age = ageData.age(i);
            lineDataWithAgeSession.lineData{1,i}(j).session = sessionName;
        end
    end

    % Save the modified lineData with age and session columns
    outputDir = fullfile('/oak/stanford/groups/kalanit/biac2/kgs/projects/Kids_AcrossYears/FMRI/Toonotopy/results/jewelia'); % Specify your output directory here
    
    % Construct the output filename
    outputFilename = fullfile(outputDir, [ erase(lineData, '.mat') '_with_age_session.mat']);

    % Save the modified lineData with age and session columns
    save(outputFilename, 'lineDataWithAgeSession');
end
