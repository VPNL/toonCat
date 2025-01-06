
% toonCat_computeSingleCategoryContrastMaps

% This scripts loads a GLM in inplane view and computes contrast maps in which
% a category is contrasted with all other domains - leaving out the other
% category from the same domain.
% For instance: words versus all others (except numbers)

% This works only if the analysis has been done with fLocAnalysis.m and the
% mrInit_params.mat variable has been saved.


%clear all
%sessions = {'AW05_190929_time_05_2'
   %'SD06_181117_time_03_2'
% %'ENK05_181201_time_03_1'
% %'CLC06_190912_time_04_1'
% 'ED07_190824_time_04_2'
% 'ENK05_190203_time_03_2'
% % 'RJ09_181110_time_03_2'
% 'INW06_191006_time_04_1'
% 'RJ09_190810_time_04_1'
% % 'AOK07_190203_time_03_2'
% % 'CS11_181215_time_03_2'
% 'GEJA09_190921_time_04_1'
% 'MDT09_191027_time_03_2'
% % 'DAPA10_181201_time_03_2'
% 'STM10_190903_time_03_2'
% 'DAPA10_190921_time_04_1'
% % 'CGSA11_190910_time_04_1'
% 'OS12_190724_time_06_1'};

%sessions = {
%'CR24_181106_time_03_2'
%'CS22_190217_time_03_1'
%'GB23_190117_time_03_1'
%'JEW23_181211_time_03_1'

%'JP23_170111_time_02_1'
%'JP25_01112017'
%'KM25_181204_time_03_1'
%'MW23_190306_time_03_1'
%'NAV22_181218_time_03_1'
%'NC24_190217_time_03_1'
%'TL24_190428_time_03_1'
%'TL24_04232015'
%};

sessions = {
%     %'050317_em'
%     %'es103118'
%     %'jw103018'
%'041817_mg'
%     %'mh102018'
%     %'MN181023'
%     %'MZ190410'
%     %'SP171101'
%     %'ST25'
%     %'TH181012'



'JG24_170109_time_04_1'
%'MSH28_181008_time_03_1'
%'KG22_190128_time_03_1'
%'DRS22'
%'MBA24_190130_time_03_1'
% 'df032518'
%'VN26'
};
%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Enter here the name of the GLM
GLMName = 'GLM_3runs_LowMotionRunsIncluded'

DataDir='/oak/stanford/groups/kalanit/biac2/kgs/projects/Kids_AcrossYears/FMRI/Localizer/data_toonCat/';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% move to session directory and initialize inplane view
for s = 1:length(sessions)
session = sessions{s};
        
% we hava e nested data structure, so we need to identify the subject
% ID   
%idx = strfind(session, '_');
%subject = session(1:idx(1)-1);
subject = session;
sessionPath = [DataDir  '/' session];
% move into the sessions directory
cd(sessionPath)

% init hidden Inplane view
hI = initHiddenInplane('GLMs');

load('mrSESSION.mat')
%load('mrInit_params.mat');
whichGLM = contains({dataTYPES(4).scanParams.annotation}, 'GLM_3runs_LowMotionRunsIncluded' );


scan = find(whichGLM);
%exactGLMName = dataTYPES(4).scanParams(scan).annotation;
hI = setCurScan(hI,scan);

%% This part is from Anthonys fLocAnalysis Script
% complile list of all conditions in parfiles
[cond_nums, conds] = deal([]); cnt = 0;
%for rr = 1:length(params.functionals)
for rr = 1:length(mrSESSION.functionals)
    %fid = fopen(params.parfile{rr}, 'r');
    fid = fopen(dataTYPES(3).scanParams(rr).parfile, 'r')
    while ~feof(fid)
        ln = fgetl(fid); cnt = cnt + 1;
        if isempty(ln); return; end; 
        ln(ln == sprintf('\t')) = '';
        prts = deblank(strsplit(ln, ' ')); 
        prts(cellfun(@isempty, prts)) = [];
        cond_nums(cnt) = str2double(prts{2});
        conds{cnt} = prts{3};
    end
    fclose(fid);
end

% make a list of unique condition numbers and corresponding condition names
cond_num_list = unique(cond_nums); cond_list = cell(1, length(cond_num_list));
for cc = 1:length(cond_num_list)
    cond_list{cc} = conds{find(cond_nums == cond_num_list(cc), 1)};
end

% remove baseline from lists of conditions
bb = find(cond_num_list == 0); cond_num_list(bb) = []; cond_list(bb) = [];


% if length(cond_num_list) == 10
%     for cc = 1:2:length(cond_num_list)
%     cc = 9 % word vs all except number
%         % Contrasting category vs. all other categories not in domain
%         domain_conds = [cc cc + 1];
%         i = 0;
%         j = 1;
%         for i = 0:1
%             active_conds = cc + i;
%             control_conds = setdiff(cond_num_list, domain_conds);
%             contrast_name = [strcat(cond_list{cc + i}) '_vs_all_except_' ...
%                              strcat(cond_list{cc + j})];
%             hI = computeContrastMap2(hI,active_conds,control_conds,...
%                                      contrast_name,'mapUnits','T');
% 
%             % move to next condition
%             j = j - 1;
%         end
% 
%     end
% end

if length(cond_num_list) == 10
    for cc = 1:2:length(cond_num_list)
        % Contrasting domain vs. all other domains
        active_conds = [cc cc + 1];
        control_conds = setdiff(cond_num_list, active_conds);
        contrast_name = [strcat(cond_list{cc:cc + 1}) '_vs_all'];
        hI = computeContrastMap2(hI, active_conds, control_conds, ...
            contrast_name, 'mapUnits','T');

        % Contrasting category vs. all other categories not in domain
        domain_conds = [cc cc + 1];
        j = 1;
        for i = 0:1
            active_conds = cc + i;
            control_conds = setdiff(cond_num_list, domain_conds);
            contrast_name = [strcat(cond_list{cc + i}) '_vs_all_except_' ...
                             strcat(cond_list{cc + j})];
            hI = computeContrastMap2(hI,active_conds,control_conds,...
                                     contrast_name,'mapUnits','T');
            % Storing contrast map as nifti
            niftiFileName = [contrast_name,'.nii.gz'];
            hI = computeContrastMap2(hI, active_conds, control_conds, ...
            contrast_name, 'mapUnits','T');

            % move to next condition
            j = j - 1;
        end

    end

end

cd(sessionPath);

hg = initHiddenGray('GLMs', 1);
hi = initHiddenInplane('GLMs', 1);
ip2volAllParMaps(hi, hg,'linear');

saveSession;

clear global

end