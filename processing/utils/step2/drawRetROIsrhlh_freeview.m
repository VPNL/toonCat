function drawRetROIsrhlh_freeview(subject_dir, subject, hemi, surface, map, varexp, labels)
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
%   hemi: specify either 'lh' 'rh' or 'both'
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
        % Phase maps (mrVista wedge style)
        crng = '1.05,5.00';
        rhPhase_cmap ='1.05,232,250,59,1.60,0,255,0,2.60,0,255,255,2.75,0,0,255,2.90,86,0,252,3.14,94,3,252,3.36,148,55,255,3.67,255,3,244,3.88,255,3,3,4.16,255,127,3,4.45,255,255,0,5.00,255,255,0'
        lhPhase_cmap ='1.05,255,255,0,1.60,255,255,0,2.20,255,127,3,2.50,255,3,3,2.70,255,3,244,2.90,148,55,255,3.14,94,3,252,3.35,86,0,252,3.61,0,0,255,3.94,0,255,255,4.28,0,255,0,5.00,232,250,59'

        % Change phase map for visualization
        lhPhase_mapName = [map, '_Viz.mgz']; % remember: this is the version edited to fit Freesurfer colors!
        %mapName = [map, '_Viz.mgz'];

    case 'eccen'
        crng = '0.2,20';
    case 'eccen_ve20_KidsTeens_concat'
        crng = '0.2,20';
    case 'eccen_ve20_Adults_concat'
        crng = '0,20';
    case 'size'
        crng = '0.021,20';
        %cmap = ;
    case 'varexp'
        crng = '0,0.75';
        %cmap = ;
    case 'category'
        crng = '3,5';
    case 'category5'
        crng = '3,5';
    case 'place'
        crng = '3,5';
    case 'place5'
        crng = '3,5';
    case 'face'
        crng = '3,5';
    otherwise 
        warning('Map does not exist. Cannot open freeview')
end


% Build add-on for multiple labels
% rh_label_addon = '';
% lh_label_addon = '';
% for i = 1:length(labels)
%     label = labels{i};
%     rh_label_path = sprintf('%s/%s/label/rh.%s_toon.label', subject_dir, subject, label);
%     lh_label_path = sprintf('%s/%s/label/lh.%s_toon.label', subject_dir, subject, label);
%     
%     % Check if the label file exists for each hemisphere
%     if isfile(rh_label_path)
%         rh_label_addon = [rh_label_addon, sprintf(':label=%s:label_outline=1:label_color=black', rh_label_path)];
%     else
%         fprintf('Could not load label %s in the right hemisphere\n', label);
%     end
%     
%     if isfile(lh_label_path)
%         lh_label_addon = [lh_label_addon, sprintf(':label=%s:label_outline=1:label_color=black', lh_label_path)];
%     else
%         fprintf('Could not load label %s in the left hemisphere\n', label);
%     end
% end
rh_label_addon = '';
lh_label_addon = '';
for i = 1:length(labels)
    label = labels{i};
    
    % Define the base path for label files
    base_path = sprintf('%s/%s/label', subject_dir, subject);

    % Use a switch statement to handle different labels
    switch label
        case {'pFus_faces', 'mFus_faces', 'mOTS_words', 'pOTS_words', 'CoS_places', 'OTS_bodies'}
            suffix = 'toon.label';
        case {'IOG_faces', 'ITG_limbs', 'LOS_limbs', 'IPS_places', 'MOG_places'}
            suffix = 'toon_JC.label';
        case {'pSTS_faces', 'MTG_limbs'}
            suffix = 'adults_avg.label';
        otherwise
            error('Unknown label');
    end

    % Construct the full file paths for both hemispheres
    rh_label_path = sprintf('%s/rh.%s_%s', base_path, label, suffix);
    lh_label_path = sprintf('%s/lh.%s_%s', base_path, label, suffix);
            
    
    % Check if the label file exists for each hemisphere
    if isfile(rh_label_path)
        label_color = 'black';  % default color
        
        % Set a different color for each label
        if strcmp(label, 'pFus_faces')
            label_color = 'darkred';
        elseif strcmp(label, 'mFus_faces')
            label_color = 'red';
        elseif strcmp(label, 'OTS_bodies')
            label_color = 'yellow';
        elseif strcmp(label, 'CoS_places')
            label_color = 'lightgreen';
        elseif strcmp(label, 'VO_places')
            label_color = 'darkgreen';
        elseif strcmp(label, 'pOTS_words')
            label_color = 'darkblue';
        elseif strcmp(label, 'mOTS_words')
            label_color = 'blue';
        end
        
        rh_label_addon = [rh_label_addon, sprintf(':label=%s:label_outline=1:label_color=%s', rh_label_path, label_color)];
    else
        fprintf('Could not load label %s in the right hemisphere\n', label);
    end
    
    if isfile(lh_label_path)
        label_color = 'black';  % default color
        
        % Set a different color for each label
        if strcmp(label, 'pFus_faces')
            label_color = 'darkred';
        elseif strcmp(label, 'mFus_faces')
            label_color = 'red';
        elseif strcmp(label, 'IOG_faces')
            label_color = 'pink';
        elseif strcmp(label, 'OTS_bodies')
            label_color = 'yellow';
        elseif strcmp(label, 'CoS_places')
            label_color = 'lightgreen';
        elseif strcmp(label, 'VO_places')
            label_color = 'darkgreen';
        elseif strcmp(label, 'pOTS_words')
            label_color = 'darkblue';
        elseif strcmp(label, 'mOTS_words')
            label_color = 'blue';
        elseif strcmp(label, 'IOS_words')
            label_color = 'cyan';
        elseif strcmp(label, 'pFus_kubotaMPM')
            label_color  = 'darkred';
        elseif strcmp(label, 'mFus_kubotaMPM')
            label_color = 'red';
        elseif strcmp(label, 'pOTS_kubotaMPM')
            label_color = 'darkblue';
        elseif strcmp(label, 'mOTS_kubotaMPM')
            label_color =  'blue';
        elseif strcmp(label, 'OTS_kubotaMPM')
            label_color = 'yellow';
        elseif strcmp(label, 'PPA_kubotaMPM')
            label_color = 'lightgreen';
        end
        
        lh_label_addon = [lh_label_addon, sprintf(':label=%s:label_outline=1:label_color=%s', lh_label_path, label_color)];
    else
        fprintf('Could not load label %s in the left hemisphere\n', label);
    end
end


% Load both hemispheres in freeview
if strcmp(hemi, 'lh')
    if strcmp(map, 'phase')
        
        freeview_phase = sprintf(['freeview -f %s/%s/surf/lh.%s:curvature_method=binary:overlay=lh.%s:overlay_custom=%s:overlay_color=clearlower,clearhigher:overlay_threshold=%s:overlay_mask=%s/%s/label/lh.%s:overlay=lh.eccen.mgz:overlay_mask=%s/%s/label/lh.%s:overlay_color=colorwheel:overlay_threshold=.001,20', lh_label_addon], ...
            subject_dir, subject, surface, lhPhase_mapName, lhPhase_cmap, crng, subject_dir, subject, mask, subject_dir, subject, mask);
        system(freeview_phase);
    else
        freeview_map = sprintf(['freeview -f %s/%s/surf/lh.%s:curvature_method=binary:overlay=lh.%s:overlay_color=colorwheel,clearlower,clearhigher:overlay_threshold=%s:overlay_mask=%s/%s/label/lh.%s', lh_label_addon], ...
           subject_dir, subject, surface, mapName, crng, subject_dir, subject, mask, lh_label_addon);
        system(freeview_map);
    end

elseif strcmp(hemi,'rh')
    if strcmp(map, 'phase')
        freeview_phase = sprintf(['freeview -f %s/%s/surf/rh.%s:curvature_method=binary:overlay=rh.%s:overlay_custom=%s:overlay_color=clearlower,clearhigher:overlay_threshold=%s:overlay_mask=%s/%s/label/rh.%s:overlay=rh.eccen.mgz:overlay_mask=%s/%s/label/rh.%s:overlay_color=colorwheel:overlay_threshold=.001,20', rh_label_addon], ...
            subject_dir, subject, surface, mapName, rhPhase_cmap, crng, subject_dir, subject, mask, subject_dir, subject, mask);
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
            subject_dir, subject, surface, mapName, rhPhase_cmap, crng, subject_dir, subject, mask, subject_dir, subject, mask, ...
            subject_dir, subject, surface, lhPhase_mapName, lhPhase_cmap, crng, subject_dir, subject, mask, subject_dir, subject, mask);
        system(freeview_phase);
    elseif strcmp(map, 'eccen') || strcmp(map, 'eccen_ve20_KidsTeens_concat') || strcmp(map, 'eccen_ve20_Adults_concat')
        freeview_map = sprintf(['freeview -f %s/%s/surf/rh.%s:curvature_method=binary:overlay=%s/%s/surf/toonMaps/rh.%s:overlay_color=colorwheel,clearlower,clearhigher:overlay_threshold=%s: ' ...
            ' -f %s/%s/surf/lh.%s:curvature_method=binary:overlay=%s/%s/surf/toonMaps/lh.%s:overlay_color=colorwheel,clearlower,clearhigher:overlay_threshold=%s'], ...
            subject_dir, subject, surface, subject_dir, subject, mapName, crng,...
            subject_dir, subject, surface, subject_dir, subject, mapName, crng);
        system(freeview_map);
    elseif strcmp(map, 'category')
        freeview_map = sprintf(['freeview -f %s/%s/surf/rh.%s:curvature_method=binary:overlay=%s/%s/surf/toonCat_maps/toonCat_proj_max_maps/faceadultfacechild_vs_all_rh_proj_max.mgh:overlay_color=colorwheel,inverse:overlay_threshold=%s:' ...
            ':overlay=%s/%s/surf/toonCat_maps/toonCat_proj_max_maps/Word_vs_all_except_Number_rh_proj_max.mgh:overlay_color=colorwheel,inverse:overlay_threshold=%s:'...
            ':overlay=%s/%s/surf/toonCat_maps/toonCat_proj_max_maps/BodyLimb_vs_all_rh_proj_max.mgh:overlay_color=colorwheel,inverse:overlay_threshold=%s:'...
            ':overlay=%s/%s/surf/toonCat_maps/toonCat_proj_max_maps/PlaceHouse_vs_all_rh_proj_max.mgh:overlay_color=colorwheel,inverse:overlay_threshold=%s:' rh_label_addon ...
            '  -f %s/%s/surf/lh.%s:curvature_method=binary:overlay=%s/%s/surf/toonCat_maps/toonCat_proj_max_maps/faceadultfacechild_vs_all_lh_proj_max.mgh:overlay_color=colorwheel,inverse:overlay_threshold=%s:' ...
            ':overlay=%s/%s/surf/toonCat_maps/toonCat_proj_max_maps/Word_vs_all_except_Number_lh_proj_max.mgh:overlay_color=colorwheel,inverse:overlay_threshold=%s:'...
            ':overlay=%s/%s/surf/toonCat_maps/toonCat_proj_max_maps/BodyLimb_vs_all_lh_proj_max.mgh:overlay_color=colorwheel,inverse:overlay_threshold=%s:'...
            ':overlay=%s/%s/surf/toonCat_maps/toonCat_proj_max_maps/PlaceHouse_vs_all_lh_proj_max.mgh:overlay_color=colorwheel,inverse:overlay_threshold=%s:' lh_label_addon], ...
            subject_dir, subject, surface, subject_dir, subject, crng, ...
            subject_dir, subject, crng, ...
            subject_dir, subject, crng, ...
            subject_dir, subject, crng, ...
            subject_dir, subject, surface, subject_dir, subject, crng, ...
            subject_dir, subject, crng, ...
            subject_dir, subject, crng, ...
            subject_dir, subject, crng);
        system(freeview_map);
    elseif strcmp(map, 'category5')
        freeview_map = sprintf(['freeview -f %s/%s/surf/rh.%s:curvature_method=binary:overlay=%s/%s/surf/toonCat_maps/toonCat_proj_max_maps/Faces_vs_all_rh_proj_max.mgh:overlay_color=colorwheel,inverse:overlay_threshold=%s:' ...
            ':overlay=%s/%s/surf/toonCat_maps/toonCat_proj_max_maps/Characters_vs_all_rh_proj_max.mgh:overlay_color=colorwheel,inverse:overlay_threshold=%s:'...
            ':overlay=%s/%s/surf/toonCat_maps/toonCat_proj_max_maps/Bodies_vs_all_rh_proj_max.mgh:overlay_color=colorwheel,inverse:overlay_threshold=%s:'...
            ':overlay=%s/%s/surf/toonCat_maps/toonCat_proj_max_maps/Places_vs_all_rh_proj_max.mgh:overlay_color=colorwheel,inverse:overlay_threshold=%s:' rh_label_addon ...
            '  -f %s/%s/surf/lh.%s:curvature_method=binary:overlay=%s/%s/surf/toonCat_maps/toonCat_proj_max_maps/Faces_vs_all_lh_proj_max.mgh:overlay_color=colorwheel,inverse:overlay_threshold=%s:' ...
            ':overlay=%s/%s/surf/toonCat_maps/toonCat_proj_max_maps/Characters_vs_all_lh_proj_max.mgh:overlay_color=colorwheel,inverse:overlay_threshold=%s:'...
            ':overlay=%s/%s/surf/toonCat_maps/toonCat_proj_max_maps/Bodies_vs_all_lh_proj_max.mgh:overlay_color=colorwheel,inverse:overlay_threshold=%s:'...
            ':overlay=%s/%s/surf/toonCat_maps/toonCat_proj_max_maps/Places_vs_all_lh_proj_max.mgh:overlay_color=colorwheel,inverse:overlay_threshold=%s:' lh_label_addon], ...
            subject_dir, subject, surface, subject_dir, subject, crng, ...
            subject_dir, subject, crng, ...
            subject_dir, subject, crng, ...
            subject_dir, subject, crng, ...
            subject_dir, subject, surface, subject_dir, subject, crng, ...
            subject_dir, subject, crng, ...
            subject_dir, subject, crng, ...
            subject_dir, subject, crng);
        system(freeview_map);
    elseif strcmp(map, 'place')
        freeview_map = sprintf(['freeview -f %s/%s/surf/rh.%s:curvature_method=binary:overlay=%s/%s/surf/toonCat_maps/toonCat_proj_max_maps/PlaceHouse_vs_all_rh_proj_max.mgh:overlay_color=colorwheel,inverse:overlay_threshold=%s:' rh_label_addon ...
            '  -f %s/%s/surf/lh.%s:curvature_method=binary:overlay=%s/%s/surf/toonCat_maps/toonCat_proj_max_maps/PlaceHouse_vs_all_lh_proj_max.mgh:overlay_color=colorwheel,inverse:overlay_threshold=%s:' lh_label_addon], ...
            subject_dir, subject, surface, subject_dir, subject, crng, ...
            subject_dir, subject, surface, subject_dir, subject, crng);
        system(freeview_map);
    elseif strcmp(map, 'face')
        freeview_map = sprintf(['freeview -f %s/%s/surf/rh.%s:curvature_method=binary:overlay=%s/%s/surf/toonCat_maps/toonCat_proj_max_maps/faceadultfacechild_vs_all_rh_proj_max.mgh:overlay_color=colorwheel,inverse:overlay_threshold=%s:' rh_label_addon ...
            '  -f %s/%s/surf/lh.%s:curvature_method=binary:overlay=%s/%s/surf/toonCat_maps/toonCat_proj_max_maps/faceadultfacechild_vs_all_lh_proj_max.mgh:overlay_color=colorwheel,inverse:overlay_threshold=%s:' lh_label_addon], ...
            subject_dir, subject, surface, subject_dir, subject, crng, ...
            subject_dir, subject, surface, subject_dir, subject, crng);
        system(freeview_map);
    elseif strcmp(map, 'place5')
        freeview_map = sprintf(['freeview -f %s/%s/surf/rh.%s:curvature_method=binary:overlay=%s/%s/surf/toonCat_maps/toonCat_proj_max_maps/Places_vs_all_rh_proj_max.mgh:overlay_color=colorwheel,inverse:overlay_threshold=%s:' rh_label_addon ...
            '  -f %s/%s/surf/lh.%s:curvature_method=binary::overlay=%s/%s/surf/toonCat_maps/toonCat_proj_max_maps/Places_vs_all_lh_proj_max.mgh:overlay_color=colorwheel,inverse:overlay_threshold=%s:' lh_label_addon], ...
            subject_dir, subject, surface, subject_dir, subject, crng, ...
            subject_dir, subject, surface, subject_dir, subject, crng);
        system(freeview_map);
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




