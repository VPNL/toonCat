function toonCat_mrvGray2fsSurf_parameterMaps(session_path, map_path, fsSession_path, fs_id)
% Transforms a mrVista gray parameter map (.mat in session/Gray/GLMs)
% into FreeSurfer-compatible surf .mgh files. Concatenates across multiple
% proj fract values when inflated maps to the freesurfer surface to account
% for contrast differences across laminar layers (fixes holes in the
% inflated maps so that they match the mrVista meshes). 
%
% Inputs
%   session_path        path to subject session folder 
%                       (ex. '/share/kalanit/biac2/kgs/projects/DynamicCategories/data/DynaCat/subj06/session1')
%   map_path:           path to .mat file storing mrVista parameter 
%                       (ex.'/share/kalanit/biac2/kgs/projects/DynamicCategories/data/DynaCat/test_subj06/session1/Gray/GLMs/faces-allMotion_vs_all.mat')
%   fsSession_path      path to fs session (ex./kalanit/anatomy/freesurferRecon/ax202306_v72)
%   fs_id               freesurferRecon subj id (ex. 'ag202309_v72')
%
% Output
%   toonCat_maps folders in both freesurferRocon/subj/surf and
%   freesurferRocon/subj/mri that contain generated nifti-1 volume
%   contrast maps and .mgh freesurfer surface maps
% 
% JKY 10/2023

% % testing as script
% map_path = '/share/kalanit/biac2/kgs/projects/DynamicCategories/data/DynaCat/test_subj06/session1/Gray/GLMs/faces-allMotion_vs_all.mat';
% %contrast_name = 'faces-allMotion_vs_all.mat';
% session_path = '/share/kalanit/biac2/kgs/projects/DynamicCategories/data/DynaCat/test_subj06/session1';
% fsSession_path = '/share/kalanit/biac2/kgs/anatomy/freesurferRecon/ag202309_v72';
% fs_id = 'ag202309_v72';

%% load session info
cd(session_path);
load mrSESSION.mat
load('mrInit_params.mat', 'params')

% get paths to subject data in freesurferRecon
mri_dir = fullfile(fsSession_path, 'mri');
surf_dir = fullfile(fsSession_path, 'surf');
% get datatype and contrast name from inputed map path
[~, dt] = fileparts(fileparts(map_path));
[~, map_name] = fileparts(map_path);

%% create registration file if it doesn't exist
reg = fullfile(fsSession_path,'surf','register.dat');
if ~isfile(reg)
 origPath = [fsSession_path, '/mri/orig.mgz'];
 outFile = [fsSession_path, '/surf/register.dat'];
 cmd = ['tkregister2 --mov ' origPath ' --noedit --s ' fs_id ' --regheader --reg ' outFile];
 unix(cmd)
end

%% generate FreeSurfer parameter map file from mrVista parameter map
hg = initHiddenGray(dt, 1);
hg = loadParameterMap(hg, map_path);
hg = loadAnat(hg);

nifti1_fileName = [map_name '.nii.gz'];
nifti1_mri_filepath = fullfile(mri_dir, nifti1_fileName);

functionals2itkGray(hg, 1, nifti1_mri_filepath); % converts gray .mat contrast file into vistasoft nifti and then into nifti-1

cd(mri_dir);
unix(['mri_convert -ns 1 -odt float -rt nearest -rl orig.mgz ' ...
    map_name '.nii.gz ' map_name '.nii.gz --conform']);

%% convert nifti-1 to surf mgh map
% generate FreeSurfer surface files for each hemisphere by making a map at
% each proj_frac value and concatenating them (fixes holes in maps caused
% by laminar layer differences in activaiton)
nifti1_surf_filepath = fullfile(surf_dir, nifti1_fileName);
movefile(nifti1_mri_filepath, nifti1_surf_filepath); % move nifti-1 into freesurferRecon/subj/surf for inflation
cd(surf_dir);

proj_values = [-0.5:0.1:0.5];
created_maps = {};
% rh
for p = 1:length(proj_values)
    curr_filename = strcat(map_name, '_rh_proj_', num2str(proj_values(p)), '.mgh');
    unix(['mri_vol2surf --mov ', nifti1_surf_filepath, ' ', ...
            '--reg register.dat --hemi rh --interp trilin --o ', ...
            fullfile(surf_dir, curr_filename), ...
            ' --projfrac ', num2str(proj_values(p))]); 
    created_maps = [created_maps, {curr_filename}];
end

rh_proj_max_filename = [map_name, '_rh_proj_max.mgh'];
if exist(rh_proj_max_filename)
    prev_max_map = rh_proj_max_filename;
    delete(prev_max_map)
end
unix(['mri_concat --i ', strcat(map_name, '_rh_proj_*'), ...
        ' --o ', rh_proj_max_filename, ' --max']);

% lh
for p = 1:length(proj_values)
    curr_filename = strcat(map_name, '_lh_proj_', num2str(proj_values(p)), '.mgh');
    unix(['mri_vol2surf --mov ', nifti1_surf_filepath, ' ', ...
            '--reg register.dat --hemi lh --interp trilin --o ', ...
            fullfile(surf_dir, curr_filename), ...
            ' --projfrac ', num2str(proj_values(p))]); % left hemi
    created_maps = [created_maps, {curr_filename}];
end

lh_proj_max_filename = [map_name, '_lh_proj_max.mgh'];
if exist(lh_proj_max_filename)
    prev_max_map = lh_proj_max_filename;
    delete(prev_max_map)
end
unix(['mri_concat --i ', strcat(map_name, '_lh_proj_*'), ...
        ' --o ', lh_proj_max_filename, ' --max']);

%% put surf and nifti-1 contrast maps into their own folders to keep things tidy
% make new folders
toonCat_surf_folder_path = fullfile(surf_dir, 'toonCat_maps');
if ~exist(toonCat_surf_folder_path, 'dir')
    mkdir(toonCat_surf_folder_path);
end
toonCat_surf_folder_path_all_maps = fullfile(toonCat_surf_folder_path, 'toonCat_all_maps', map_name);
if ~exist(toonCat_surf_folder_path_all_maps, 'dir')
    mkdir(toonCat_surf_folder_path_all_maps);
end

% put maps into folders
for i = 1:length(created_maps)
    curr_map_filepath = fullfile(surf_dir, created_maps(i));
    movefile(cell2mat(curr_map_filepath), fullfile(toonCat_surf_folder_path_all_maps, cell2mat(created_maps(i))));
end

% put proj_max maps in their own folder
toonCat_surf_folder_path_proj_max_maps = fullfile(toonCat_surf_folder_path, 'toonCat_proj_max_maps');
if ~exist(toonCat_surf_folder_path_proj_max_maps, 'dir')
    mkdir(toonCat_surf_folder_path_proj_max_maps);
end
movefile(fullfile(surf_dir, lh_proj_max_filename), fullfile(toonCat_surf_folder_path_proj_max_maps, lh_proj_max_filename));
movefile(fullfile(surf_dir, rh_proj_max_filename), fullfile(toonCat_surf_folder_path_proj_max_maps, rh_proj_max_filename));

% move nifti-1 maps back into mri
toonCat_mri_folder_path = fullfile(mri_dir, 'toonCat_maps');
if ~exist(toonCat_mri_folder_path, 'dir')
    mkdir(toonCat_mri_folder_path);
end
movefile(nifti1_surf_filepath, toonCat_mri_folder_path);

