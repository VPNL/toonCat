function toonCat_getSizeEccVertex_df(sessions,group,exptDir,exptName,atlas,resultsDir)

% This script gets the vertex data for examining size v. ecc and puts it in
% a long format

% JKY 2023

% Directories
dataDir = [exptDir resultsDir];

% Initialize cell arrays to store data
sub = {};
hemi = {};
ROI = {};
slope = [];
intercept = [];
size = [];
ecc = [];
roi_index = {};


% Load the saved data file
saveFile = ['toonCat_EccVsSigma_lineData_allHemi_' exptName '_' group, '_' atlas 'ROIs.mat'];
load(fullfile(dataDir, saveFile));
%% 
% Initialize cell arrays to store the data
vertexData = {};

% Extract data and populate arrays
for subj = 1:length(sessions)
    for roi = 1:length(lineData{subj})
        numVerticesSize = numel(lineData{subj}(roi).sigma);
        numVerticesEcc = numel(lineData{subj}(roi).ecc);
        
        for v = 1:max(numVerticesSize, numVerticesEcc)
            if v <= numVerticesSize
                currentVertexSize = lineData{subj}(roi).sigma(v);
            else
                currentVertexSize = NaN;
            end
            
            if v <= numVerticesEcc
                currentVertexEcc = lineData{subj}(roi).ecc(v);
            else
                currentVertexEcc = NaN;
            end
            
            vertexData{end + 1, 1} = sessions{subj};
            vertexData{end, 2} = lineData{subj}(roi).roi;
            vertexData{end, 3} = v;
            vertexData{end, 4} = "size";
            vertexData{end, 5} = currentVertexSize;
            
            vertexData{end + 1, 1} = sessions{subj};
            vertexData{end, 2} = lineData{subj}(roi).roi;
            vertexData{end, 3} = v;
            vertexData{end, 4} = "ecc";
            vertexData{end, 5} = currentVertexEcc;
        end
    end
end

% Create a table from the collected data
dataTable = cell2table(vertexData, 'VariableNames', {'sub', 'ROI', 'Vertex', 'Parameter', 'Value'});


% Save the table to a CSV file
csvFilePath = fullfile(dataDir, ['pRFsizeEcc_vertexData_' exptName '_' group, '_' atlas 'ROIs.csv']);
writetable(dataTable, csvFilePath);

disp('Data table in long format with Subject, ROI, Vertex, Parameter, and Value created and saved.');
