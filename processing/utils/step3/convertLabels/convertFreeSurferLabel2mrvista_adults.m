function convertFreeSurferLabel2mrvista_adults(subs,hemis,labels)
%
% This function converts labels/ROIs drawn in freesurfer to files that can
% be read by mrVista. It first converts .label to a nifti using
% freeSurferLabel2niftiROI then converts nifti to .mat using 
% niftiROI2mrVistaROI.m for subjects in the Kids Across Years format.
%
%   subjects: list of subjects
%   hemis: list of hemispheres we want labels from
%   labels: list of labels to convert
%

for s=1:length(subs)

    % setSessions information
    subID = subs{s}
    [sessions, fs_sessions] = setSessions_kidsToon(subID, 1);

    setup.vistaDir ='/oak/stanford/groups/kalanit/biac2/kgs/projects/Kids_AcrossYears/FMRI/Toonotopy/data';
    setup.fsDir = '/oak/stanford/groups/kalanit/biac2/kgs/anatomy/freesurferRecon/Kids_AcrossYears';
    setup.subID = subID;
    setup.fsSession = fs_sessions;
    
    % Set FreeSurfer Directory
    k_AY_base_dir = setup.fsDir;
    setenv('SUBJECTS_DIR', k_AY_base_dir);
    
    % Reference these directories
    vistaDir = fullfile(setup.vistaDir, setup.subID);
    map_dir = fullfile(vistaDir, 'FreesurferFormat');
    
    % Convert .label files to nifti format
    freesurferLabel2niftiROI(setup.fsDir, setup.fsSession, hemis, labels, vistaDir)
    
    % Convert nifti to .mat
    for h=1:length(hemis)
        for l=1:length(labels)
            cd(vistaDir)
    
            % define variables
            niftiDir = fullfile(vistaDir,'3DAnatomy/niftiROIs');
            roiDir = fullfile(vistaDir,'3DAnatomy/ROIs');  
            roiPath = fullfile(niftiDir,[hemis{h}, '.', labels{l},'_toon.nii.gz']);
            ni = readFileNifti(roiPath);
            savename = [hemis{h},'.',labels{l},'_toon.mat'];

            if ~exist(roiDir, 'dir')
                mkdir(roiDir)
            end

            % Check if the file exists
            if exist(roiPath, 'file') == 2
                niftiROI2mrVistaROI(roiPath, 'color', [0 0 0], 'spath', roiDir, 'name', savename)
            else
                disp(['Skipping subject:', subID, ', ROI:', hemis{h}, '.', labels{l}, '_toon.nii.gz - File does not exist']);
            end
            
         %niftiROI2mrVistaROI(roiPath,'color',[0 0 0],'spath',roiDir,'name',savename)
    
        end
    end
end

