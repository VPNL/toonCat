function toon_partialInflate(subjectsDir, subject, hemis, iterations)
% function toon_partialInflate
%
% This function partially inflates the freesurfer surface. The degree of 
% inflation can be adjusted to your liking. 0 is less inflated and 20 is 
% very inflated.
%
%   subject: A string of the sub name;
%   hemis: A cell array of hemisphere names - hemispheres = {'lh', 'rh'};
%   iterations: A vector of iteration values - thresholds = [5];
%   subjectsDir: A string specifying the FreeSurfer subjects directory - subjects_dir = '/path/to/subjects/dir';
% 

% Set directory
SUBJECTS_DIR = subjectsDir;

% Run partial inflation for rh and lh

for h=1:length(hemis)
    for n=1:numel(iterations)
        dir0 = sprintf('%s/%s/surf', SUBJECTS_DIR, subject);
        movefile(sprintf('%s/%s.sulc', dir0, hemis{h}), sprintf('%s/%s.sulc.bak', dir0, hemis{h})); % Keep a backup
        cmd = sprintf('mris_inflate -n %d %s/%s.smoothwm %s/%s.semiinflated_%.0f', iterations(n), dir0, hemis{h}, dir0, hemis{h}, iterations(n));
        system(cmd); % Run mris_inflate command
        movefile(sprintf('%s/%s.sulc', dir0, hemis{h}), sprintf('%s/%s.sulcsemiinflated_%.0f', dir0, hemis{h}, iterations(n))); % Rename sulc file as semi-inflated
        movefile(sprintf('%s/%s.sulc.bak', dir0, hemis{h}), sprintf('%s/%s.sulc', dir0, hemis{h})); % Rename original sulc file back to original name
    end
end
