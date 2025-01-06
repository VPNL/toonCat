function toon_createVarExpMasks(subject, hemispheres, thresholds, subjects_dir)
%CREATE_MASKS Create thresholded masks and labels using FreeSurfer commands
%
%   subject: string of subject name;
%   hemispheres: A cell array of hemisphere names - hemispheres = {'lh', 'rh'};
%   thresholds: A vector of threshold values - thresholds = [0.05, 0.1, 0.2];
%   subjects_dir: A string specifying the FreeSurfer subjects directory - subjects_dir = '/path/to/subjects/dir';
% 

% Loop over hemispheres, and thresholds
for h = 1:numel(hemispheres)
    for t = 1:numel(thresholds)

        % Create thresholded mask
        cmd = sprintf('mri_binarize --i %s/%s/surf/%s.varexp.mgz --min %g --o %s/%s/surf/%s.ve_%.0f.thresh.mgz', ...
            subjects_dir, subject, hemispheres{h}, thresholds(t), subjects_dir, subject, hemispheres{h}, thresholds(t)*100);
        system(cmd);

        % Create label from mask for drawing
        cmd = sprintf('mri_cor2label --i %s/%s/surf/%s.ve_%.0f.thresh.mgz --surf %s %s --id 1 --l %s/%s/label/%s.ve_%.0f.thresh.label', ...
            subjects_dir, subject, hemispheres{h}, thresholds(t)*100, subject, hemispheres{h}, subjects_dir, subject, hemispheres{h}, thresholds(t)*100);
        system(cmd);

        
    end
end


end
