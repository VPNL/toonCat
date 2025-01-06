function convertFreeSurferLabel2mrvista(subs,session_num,hemis,labels,atlas,group)
%
% This function converts labels/ROIs drawn in freesurfer to files that can
% be read by mrVista. It first converts .label to a nifti using
% freeSurferLabel2niftiROI then converts nifti to .mat using 
% niftiROI2mrVistaROI.m for subjects in the Kids Across Years format.
%
%   subjects: list of subjects
%   session_num: session number (1,2,etc.) in the Kids Across Years dataset
%   as some of the subjects have multiple sessions
%   hemis: list of hemispheres we want labels from
%   labels: list of labels to convert
%   atlas: either toon or wang atlas
%

for s=1:length(subs)

    % setSessions information
    subID = subs{s}
    [sessions, fs_sessions] = setSessions_kidsToon(subID, session_num);

    setup.vistaDir ='/oak/stanford/groups/kalanit/biac2/kgs/projects/Kids_AcrossYears/FMRI/Toonotopy/data';
    setup.fsDir='/oak/stanford/groups/kalanit/biac2/kgs/anatomy/freesurferRecon/Kids_AcrossYears';
    setup.subID = subID;
    setup.fsSession = fs_sessions;
    setup.vistaSession = sessions;
    subjid = setup.fsSession;
    
    % Set FreeSurfer Directory
    k_AY_base_dir= setup.fsDir;
    setenv('SUBJECTS_DIR', k_AY_base_dir);
    
    % Reference these directories
    if strcmp(group, 'Adults')
        vistaDir = fullfile(setup.vistaDir, setup.subID); %adults path
    else
        vistaDir = fullfile(setup.vistaDir, setup.subID, setup.vistaSession); %kids path
    end
    
    map_dir = fullfile(vistaDir, 'FreesurferFormat');

    
    % Convert .label files to nifti format
    freesurferLabel2niftiROI(setup.fsDir, setup.fsSession, hemis, labels, vistaDir, atlas)
    
    % Convert nifti to .mat
    for h=1:length(hemis)
        for l=1:length(labels)
            cd(vistaDir)
    
            % define varibles
            niftiDir = fullfile(vistaDir,'3DAnatomy/niftiROIs');
            roiDir = fullfile(vistaDir,'3DAnatomy/ROIs');  
            if ~exist(roiDir, 'dir')
                mkdir(roiDir)
            end
            %roiPath = fullfile(niftiDir,[hemis{h}, '.', labels{l},'.nii.gz']);
            roiPath = fullfile(niftiDir,[hemis{h}, '.', labels{l},'_' atlas '.nii.gz']);

            ni = readFileNifti(roiPath);
            savename = [hemis{h},'.',labels{l},'_' atlas '.mat'];
            %savename = [hemis{h},'.',labels{l},'.mat'];

            % Check if the file exists
            if exist(roiPath, 'file') == 2
                niftiROI2mrVistaROI(roiPath, 'color', [0 0 0], 'spath', roiDir, 'name', savename)
            else
                disp(['Skipping subject:', subID, ', ROI:', hemis{h}, '.', labels{l}, '_' atlas '.nii.gz - File does not exist']);
            end
            
         %niftiROI2mrVistaROI(roiPath,'color',[0 0 0],'spath',roiDir,'name',savename)
    
        end
    end
end

