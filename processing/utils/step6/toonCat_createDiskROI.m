function toonCat_createDiskROI(ROIsize, labels, hemis,subs)

% This function creates a disk ROI from a previously defined functional ROI
% and transforms it to the inplane from the gray using mrVista functions.
%
% INPUTS
% (1) ROIsize
% Input ROIsize in mm
%
% (2) labels
% Please use array of ROIs you want to convert
%
% (3) hemis
% {'rh', 'lh'}
%
% (4) subs
% Input array of subs/sessions. If you have subfolders, you will have to
% edit the subject names to include the parent folders.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Loop throguh subjects
for s=1:length(subs)

    catSession = subs{s};
    toonCat_path = fullfile('/oak/stanford/groups/kalanit/biac2/kgs/projects/Kids_AcrossYears/FMRI/Localizer/data_toonCat');
    session_path = fullfile(toonCat_path, catSession);

    % Loop through hemispheres and functional ROIs
    for h=1:length(hemis)
        for l=1:length(labels)

            cd(session_path);
            ROIdir = fullfile(session_path,'3DAnatomy/ROIs'); 
            ROIname = [hemis{h} '.' labels{l}];
            ROIpath = fullfile(ROIdir,[ROIname '.mat']);

            % If file exists, create disk ROI from center of funcitonal ROI
            if exist(ROIpath, 'file') == 2
                % % initialize hidden gray
                % hg = initHiddenGray(3, 1, [ROIname '.mat']);

                % create disk name
                ROIsizeStr = sprintf('%dmm', ROIsize);
                diskROIname = [hemis{h} '_' labels{l} '_' ROIsizeStr];
                diskROIcheck = fullfile(ROIdir, [diskROIname '.mat']);

                if ~exist(diskROIcheck, 'file')
                    disp(['Creating' diskROIname ' for subject ' subs{s}]);

                    % create new ROI
                    hg = initHiddenGray(3, 1, [ROIname '.mat']);
                    [hg, newDiskROI, layers] = makeROIdiskGray(hg, ROIsize, diskROIname, [], [], mean(hg.ROIs.coords,2));
                    [vw, status, forceSave] = saveROI(hg, newDiskROI);
                else
                    disp(['File' diskROIname ' already exists for subject ' subs{s}]);
                end
            else
                disp(['Skipping subject:', catSession, ', ROI:', ROIname '.nii.gz - File does not exist']);
            end
            
        end
    end

    clear hg

    % Get list of disk ROIs
    diskROIs_struct = dir(fullfile('./3DAnatomy/ROIs/', ['*_' num2str(ROIsize) 'mm.mat']));
    diskROIs = {diskROIs_struct.name};

    % Transform disk ROIs for this subject from gray to inplane
    hg = initHiddenGray('GLMs', 1, diskROIs);
    hi = initHiddenInplane('GLMs', 1);

    hi = vol2ipAllROIs(hg, hi);
    saveAllROIs(hi, 1, 1);

end
