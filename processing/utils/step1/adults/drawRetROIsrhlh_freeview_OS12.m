function drawRetROIsrhlh_freeview_OS12(subject_dir, subject, hemi,surface, map, varexp, labels)
%
% drawRetROIsrhlh_freeview
%
% This function loads both hemispheres in freeview with a thresholded
% retintopy map of your choosing. All other functions (actually drawing the
% ROIs) must be done in the GUI.
%
%   subject_dir: A string specifying the FreeSurfer subjects directory;
%   subject: string of subject name;
%   surface: which surface do you want? - inflated, pial, semiinflated_n
%   map: name of map you want to load - eccen, phase, varexp, size; change
%   to cell are
%   varexp: percentage of variance explained you want to be shown in the map - 10, 20;
%   labels: array of already-drawn ROIs to load
%   hemi: specity either 'lh' 'rh' or 'both'
% 
% JKY June 2023

if nargin < 7
    labels = [];
end

% Specify maps and varaince explained masks
mask = ['ve_', num2str(varexp), '.thresh.label'];
mapName = [map, '.mgz'];

% Define dictionary of color ranges and maps

switch map
    case 'phase'
        % Old phase maps (colorwheel style)
%         crng = '1.28,5';
%         rhPhase_cmap = '1.28,0,0,102,1.94,0,0,255,2.54,0,255,255,3.14,0,255,0,3.74,255,255,0,4.34,255,0,0,5,153,0,0';
%         lhPhase_cmap = '1.28,153,0,0,1.94,255,0,0,2.54,255,255,0,3.14,0,255,0,3.74,0,255,255,4.34,0,0,255,5,0,0,102';
%         
        % New phase maps (mrVista wedge style)
        crng = '1.05,5.00';
        rhPhase_cmap ='1.05,232,250,59,1.60,0,255,0,2.60,0,255,255,2.75,0,0,255,2.90,86,0,252,3.14,94,3,252,3.36,148,55,255,3.67,255,3,244,3.88,255,3,3,4.16,255,127,3,4.45,255,255,0,5.00,255,255,0'
        lhPhase_cmap ='1.05,255,255,0,1.60,255,255,0,2.20,255,127,3,2.50,255,3,3,2.70,255,3,244,2.90,148,55,255,3.14,94,3,252,3.35,86,0,252,3.61,0,0,255,3.94,0,255,255,4.28,0,255,0,5.00,232,250,59'
        %rhPhase_cmap = '1.05,165,252,3,1.57,0,255,0,2.23,0,255,255,2.70,0,0,255,3.14,94,3,252,3.67,255,3,244,4.36,255,3,3,4.71,255,127,3,4.98,255,255,0';
        %lhPhase_cmap = '1.05,255,255,0,1.57,255,127,3,2.23,255,3,3,2.70,255,3,244,3.14,94,3,252,3.67,0,0,255,4.36,0,255,255,4.71,0,255,0,4.98,165,252,3';
        % Change phase map for visualization
        rhPhase_mapName = [map, '_Viz.mgz']; % remember: this is the version edited to fit Freesurfer colors!

    case 'eccen'
        crng = '0,25';
        %cmap = ; Do we want to specify a custom color map?
    case 'size'
        crng = '0,10';
        %cmap = ;
    case 'varexp'
        crng = '0,0.75';
        %cmap = ;
    otherwise 
        warning('Map does not exist. Cannot open freeview')
end


% Build add-on for multiple labels
rh_label_addon = '';
lh_label_addon = '';
for i = 1:length(labels)
    label = labels{i};
    rh_label_path = sprintf('%s/%s/label/rh.%s_toon.label', subject_dir, subject, label);
    lh_label_path = sprintf('%s/%s/label/lh.%s_toon.label', subject_dir, subject, label);
    
    % Check if the label file exists for each hemisphere
    if isfile(rh_label_path)
        rh_label_addon = [rh_label_addon, sprintf(':label=%s:label_outline=1:label_color=black', rh_label_path)];
    else
        fprintf('Could not load label %s in the right hemisphere\n', label);
    end
    
    if isfile(lh_label_path)
        lh_label_addon = [lh_label_addon, sprintf(':label=%s:label_outline=1:label_color=black', lh_label_path)];
    else
        fprintf('Could not load label %s in the left hemisphere\n', label);
    end
end


% Load both hemispheres in freeview
if strcmp(hemi, 'lh')
    if strcmp(map, 'phase')
        freeview_phase = sprintf(['freeview -f %s/%s/surf/lh.%s:curvature_method=binary:overlay=lh.%s:overlay_custom=%s:overlay_color=clearlower,clearhigher:overlay_threshold=%s:overlay_mask=%s/%s/label/lh.%s:overlay=lh.eccen.mgz:overlay_mask=%s/%s/label/lh.%s:overlay_color=colorwheel:overlay_threshold=.001,20', lh_label_addon], ...
            subject_dir, subject, surface, mapName, lhPhase_cmap, crng, subject_dir, subject, mask, subject_dir, subject, mask);
        system(freeview_phase);
    else
        freeview_map = sprintf(['freeview -f %s/%s/surf/lh.%s:curvature_method=binary:overlay=lh.%s:overlay_color=colorwheel,clearlower,clearhigher:overlay_threshold=%s:overlay_mask=%s/%s/label/lh.%s', lh_label_addon], ...
           subject_dir, subject, surface, mapName, crng, subject_dir, subject, mask, lh_label_addon);
        system(freeview_map);
    end

elseif strcmp(hemi,'rh')
    if strcmp(map, 'phase')
        freeview_phase = sprintf(['freeview -f %s/%s/surf/rh.%s:curvature_method=binary:overlay=rh.%s:overlay_custom=%s:overlay_color=clearlower,clearhigher:overlay_threshold=%s:overlay_mask=%s/%s/label/rh.%s:overlay=rh.eccen.mgz:overlay_mask=%s/%s/label/rh.%s:overlay_color=colorwheel:overlay_threshold=.001,20', rh_label_addon], ...
            subject_dir, subject, surface, rhPhase_mapName, rhPhase_cmap, crng, subject_dir, subject, mask, subject_dir, subject, mask);
        system(freeview_phase);
    else
        freeview_map = sprintf(['freeview -f %s/%s/surf/rh.%s:curvature_method=binary:overlay=rh.%s:overlay_color=colorwheel,clearlower,clearhigher:overlay_threshold=%s:overlay_mask=%s/%s/label/rh.%s ',rh_label_addon], ...
            subject_dir, subject, surface, mapName, crng, subject_dir, subject, mask);
        system(freeview_map);
    end
elseif strcmp(hemi,'both')
    if strcmp(map, 'phase')
        freeview_phase = sprintf(['freeview -f %s/%s/surf/rh.%s:curvature_method=binary:overlay=rh.%s:overlay_custom=%s:overlay_color=clearlower,clearhigher:overlay_threshold=%s:overlay_mask=%s/%s/label/rh.%s:overlay=rh.eccen.mgz:overlay_mask=%s/%s/label/rh.%s:overlay_color=colorwheel:overlay_threshold=.001,20', rh_label_addon, ...
            ' -f %s/%s/surf/lh.%s:curvature_method=binary:overlay=lh.%s:overlay_custom=%s:overlay_color=clearlower,clearhigher:overlay_threshold=%s:overlay_mask=%s/%s/label/lh.%s:overlay=lh.eccen.mgz:overlay_mask=%s/%s/label/lh.%s:overlay_color=colorwheel:overlay_threshold=.001,20', lh_label_addon], ...
            subject_dir, subject, surface, rhPhase_mapName, rhPhase_cmap, crng, subject_dir, subject, mask, subject_dir, subject, mask, ...
            subject_dir, subject, surface, mapName, lhPhase_cmap, crng, subject_dir, subject, mask, subject_dir, subject, mask);
        system(freeview_phase);
    else
        freeview_map = sprintf(['freeview -f %s/%s/surf/rh.%s:curvature_method=binary:overlay=rh.%s:overlay_color=colorwheel,clearlower,clearhigher:overlay_threshold=%s:overlay_mask=%s/%s/label/rh.%s ' ...
            ' -f %s/%s/surf/lh.%s:curvature_method=binary:overlay=lh.%s:overlay_color=colorwheel,clearlower,clearhigher:overlay_threshold=%s:overlay_mask=%s/%s/label/lh.%s'], ...
            subject_dir, subject, surface, mapName, crng, subject_dir, subject, mask, rh_label_addon, ...
            subject_dir, subject, surface, mapName, crng, subject_dir, subject, mask, lh_label_addon);
        system(freeview_map);
    end
else
    disp('Error: Specify hemisphere.')
end




