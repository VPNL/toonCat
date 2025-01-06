function toon_installSegmentation(session_path)
% 
% Installs segmentation for visualizations in FreeSurfer
%
% Inputs
% session_path: path to subject's session folder, ex. '/share/kalanit/biac2/kgs/projects/DynamicCategories/data/DynaCat/subj-01/session1/'
%

%% Default inputs
if notDefined('session_path')
    fprintf(1,'Error, you need to define a session_path \n');
    return
end

%% Checks
% Check and validate inputs and path to vistasoft
if isempty(which('mrVista'))
    vista_path = 'https://github.com/vistalab/vistasoft';
    error(['Add vistasoft to your matlab path: ', vista_path]);
end

cd(session_path);

%% Load initialized session
load mrInit_params.mat
load mrSESSION.mat

% Open hidden inplane
hi = initHiddenInplane('MotionComp_RefScan1', 1);

%% Install segmentation
% Guess class file path
pattern = fullfile(pwd, '3DAnatomy', '*class*nii*');
w = dir(pattern);
if ~isempty(w),  
    defaultClass = fullfile(pwd, '3DAnatomy', w(1).name);
end
if exist(defaultClass)
    installSegmentation([],[],defaultClass, 3); 
else %open GUI prompt for file name
    installSegmentation([],[],[],3); 
end