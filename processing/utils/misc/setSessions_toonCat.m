function [session, fs_session] = setSessions_toonCat(subjInitials, sessionNr, varargin)
%
% This function sets up a dictionary for toonotopy sessions and their
% corresponding freesurfer sessions within each subject. Some subjects have
% multiple sessions.
%
% JC 2023

% Check inputs for extra test folder flag
if nargin<3 
    testFolder = [];
else
    testFolder = varargin{1};
end

% Define map of subject initials to cell array of {toon_session, fs_session}
M = containers.Map();

% kids
M('AOK07') = {{'AOK07_190317_19994_time_03_1', 'AOK07_scn181201_recon0920_v6'}, ...
    {'AOK07_191207_21927_time_04_1', 'AOK07_scn191214_recon0920_v6'}};
M('AW05') = {{'AW05_190928_21389_time_05_1', 'AW05_scn190929_recon0920_v6'}};
M('CGSA11') = {{'CGSA11_190112_19475_time_03_1', 'CGSA11_scn181028_recon0920_v6'}, ...
    {'CGSA11_190921_21340_time_04_1', 'CGSA11_scn191003_recon0920_v6'}};
M('CLC06') = {{'CLC06_190912_21275_time_04_1', 'CLC06_scn190924_recon0920_v6'}};
M('CS11') = {{'CS11_190203_19652_time_03_1', 'CS11_scn181110_recon0920_v6'}, ...
    {'CS11_191012_21489_time_04_1', 'CS11_scn191103_recon0920_v6'}};
M('DAPA10') = {{'DAPA10_190112_19476_time_03_1', 'DAPA10_scn181028_recon0920_v6'}, ...
    {'DAPA10_191012_21490_time_04_1', 'DAPA10_scn191123_recon0920_v6'}};
M('DJM06') = {{'DJM06_191207_21923_time_04_1', 'DJM06_scn191006_recon0920_v6'}};
M('ED07') = {{'ED07_190119_19532_time_03_1', 'ED07_scn181020_recon0920_v6'}, ...
    {'ED07_190914_21286_time_04_1', 'ED07_scn190824_recon0920_v6'}};
M('ENK05') = {{'ENK05_190317_19993_time_03_1', 'ENK05_scn181201_recon0920_v6'}, ...
    {'ENK05_191208_21930_time_04_1', 'ENK05_scn191214_recon0920_v6'}};
M('GEJA09') = {{'GEJA09_190921_21343_time_04_1', 'GEJA09_scn200111_recon0920_v6'}};
M('INW06') = {{'INW06_181215_19358_time_03_1', 'INW06_scn180929_recon0920_v6'}, ...
    {'INW06_191103_21656_time_04_1', 'INW06_scn200112_recon0920_v6'}};
M('MDT09') = {{'MDT09_191006_21450_time_03_1', 'MDT09_scn191027_recon0920_v6'}};
M('OS12') = {{'OS12_190725_20947_time_06_1', 'OS12_scn190724_recon0920_v6'}};
M('RHSA06') = {{'RHSA06_190824_21157_time_04_1', 'RHSA06_scn190928_recon0920_v6'}};
M('RJ09') = {{'RJ09_190112_19471_time_03_1', 'RJ09_scn181028_recon0920_v6'}, ...
    {'RJ09_190914_21289_time_04_1', 'RJ09_scn191027_recon0920_v6'}};
M('RJM10') = {{'RJM10_191207_21922_time_04_1', 'RJM10_scn191006_recon0920_v6'}};
M('SD06') = {{'SD06_190119_19533_time_03_1', 'SD06_scn181020_recon0920_v6'}, ...
    {'SD06_190914_21287_time_04_1', 'SD06_scn190824_recon0920_v6'}};
M('SERA10') = {{'SERA10_21156_190824_time_04_1', 'SERA10_scn191214_recon0920_v6'}};
M('STM10') = {{'STM10_190903_21220_time_03_1', 'STM10_scn191001_recon0920_v6'}};
M('STM10') = {{'STM10_190903_21220_time_03_1', 'STM10_scn191001_recon0920_v6'}};

% adults
M('CR24') = {{'CR24', 'CR24_scn181106_recon1121_v6'}};
M('CS22') = {{'CS22', 'CS22_scn190217_recon1121_v6'}};
M('DF') = {{'DF', 'df201801_v6'}};
M('DRS22') = {{'DRS22', 'DRS22_scn190506_recon1121_v6'}};
M('ES') = {{'ES', 'es201810_v6'}};
M('EM') = {{'EM', 'EM_scn201611_recon0723_v6'}};
M('GB23') = {{'GB23', 'GB23_scn190117_recon1121_v6'}};
M('JEW23') = {{'JEW23', 'JEW23_scn181211_recon1121_v6'}};
M('JG24') = {{'JG24', 'JG24_scn150426_recon1121_v6'}};
M('JP23') = {{'JP23', 'JP23_scn201708_recon0723_v6'}};
M('JW') = {{'JW', 'jw201810_v6'}};
M('KG22') = {{'KG22', 'KG22_scn190128_recon1121_v6'}};
M('KGS') = {{'KGS', 'KGS_scn201708_recon0723_v6'}};
M('KM25') = {{'KM25', 'KM25_scn181204_recon1121_v6'}};
M('MBA24') = {{'MBA24', 'MBA24_scn190130_recon1121_v6'}};
M('MBH') = {{'MBH', 'mbh201811_v6'}};
M('MG') = {{'MG', 'MG_scn201708_recon0723_v6'}};
M('MJH25') = {{'MJH25', 'MJH25_scn180513_recon1121_v6'}};
M('MN') = {{'MN', 'MN_scn201701_recon0723_v6'}};
M('MW23') = {{'MW23', 'MW23_scn190306_recon1121_v6'}};
M('MSH28') = {{'MSH28', 'MSH28_scn190109_recon1121_v6'}};
M('MZ23') = {{'MZ23', 'MZ23_scn190528_recon1121_v6'}};
M('NAV22') = {{'NAV22', 'NAV22_scn181218_recon1121_v6'}};
M('NC24') = {{'NC24', 'NC24_scn190217_recon1121_v6'}};
M('SP') = {{'SP', 'sp201803_v6'}};
M('ST25') = {{'ST25', 'ST25_scn190424_recon1121_v6'}};
M('TH') = {{'TH', 'th201810_v6'}};
M('TL24') = {{'TL24', 'TL24_scn190428_recon0723_v6'}};
M('VN26') = {{'VN26', 'VN26_scn190501_recon1121_v6'}};

% Check that subject exists
if ~isKey(M, subjInitials)
    error('[%]: Subject does not exist!', mfilename)
end

% Check sessionNr
if sessionNr <= 0 || sessionNr > length(M(subjInitials))
    error('[%]: Cannot find sessionNr!', mfilename)
else
    cell = M(subjInitials);
    session = cell{sessionNr}{1};
    fs_session = cell{sessionNr}{2};
    % JC: original includes code to append testFolder suffix to session
    % name, which I omitted
end

return