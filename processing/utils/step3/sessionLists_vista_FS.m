%% Initialize session lists: mrVista files

sessions = struct;

%'AW05/AW05_190928_21389_time_05_1'; age 8
%'SD06/SD06_190119_19533_time_03_1'; age 9
sessions.vistaKids = {'ENK05/ENK05_190317_19993_time_03_1';
    'CLC06/CLC06_190912_21275_time_04_1';
    'ED07/ED07_190914_21286_time_04_1';
    'ENK05/ENK05_191208_21930_time_04_1'; 
    %'RJ09/RJ09_190112_19471_time_03_1'; % check this sub!
    'INW06/INW06_191103_21656_time_04_1'};

sessions.vistaTeens = {'RJ09/RJ09_190914_21289_time_04_1';
    'AOK07/AOK07_191207_21927_time_04_1';
    'CS11/CS11_190203_19652_time_03_1';
    'GEJA09/GEJA09_190921_21343_time_04_1'; % check the labels
    'MDT09/MDT09_191006_21450_time_03_1';
    'DAPA10/DAPA10_190112_19476_time_03_1';
    'STM10/STM10_190903_21220_time_03_1'; % check the labels
    'DAPA10/DAPA10_191012_21490_time_04_1';
    'CGSA11/CGSA11_190921_21340_time_04_1';  
    'OS12/OS12_190725_20947_time_06_1'};

sessions.vistaKidsTeens = [sessions.vistaKids; sessions.vistaTeens];

% sessions.vistaAdults = {'CR24/CR24_scn110618';
%     'CS22/CS22_scn021719';
%     'EM/em201611';
%     'ES/es201810';
%     'GB23/GB23_scn011719';
%     'JEW23/JEW23_scn121118';
%     'JP23/JP23_scn201708';
%     'JW/jw201810';
%     'KGS/KGS_scn201708';
%     'KM25/KM25_scn120418';
%     'MG/mg201708';
%     'MJH25/T1';
%     'MN/mn201701';
%     'MW23/MW23_scn030619';
%     'MZ23';
%     'NAV22/NAV22_scn121818';
%     'NC24/NC24_scn021719';
%     'SP/sp201803';
%     'ST25/st201904';
%     'TH/thc201810';
%     'TL24/TL24_scn042819'};

sessions.vistaAdults = {'CR24';
    'CS22';
    'EM';
    'ES';
    'GB23';
    'JEW23';
    'JP23';
    'JW';
    %'KGS';
    'KM25';
    'MG';
    'MJH25';
    'MN';
    'MW23';
    'MZ23';
    'NAV22';
    'NC24';
    'SP';
    'ST25';
    'TH';
    'TL24';
    'JG24';
    'MSH28';
    'KG22';
    'VN26';
    'DRS22';
    'MBA24';
    'DF'};

sessions.vistaAll = [sessions.vistaKidsTeens; sessions.vistaAdults];

%% Initialize session lists: FreeSurfer files

%'AW05_scn190929_recon0920_v6';
%'SD06_scn181020_recon0920_v6';
sessions.fsKids = {
    'ENK05_scn181201_recon0920_v6';
    'CLC06_scn190924_recon0920_v6';
    'ED07_scn190824_recon0920_v6';
    'ENK05_scn191214_recon0920_v6';
    'RJ09_scn181028_recon0920_v6';
    'INW06_scn200112_recon0920_v6'};
sessions.kidsAges = [10, 11, 11, 11, 12, 12];

sessions.fsTeens = {'RJ09_scn191027_recon0920_v6';
    'AOK07_scn191214_recon0920_v6';
    'CS11_scn181110_recon0920_v6';
    'GEJA09_scn200111_recon0920_v6';
    'MDT09_scn191027_recon0920_v6';
    'DAPA10_scn181028_recon0920_v6';
    'STM10_scn191001_recon0920_v6';
    'DAPA10_scn191123_recon0920_v6';
    'CGSA11_scn191003_recon0920_v6';
    'OS12_scn190724_recon0920_v6'};
sessions.teensAges = [13, 13, 14, 14, 14, 15, 15, 16, 17, 17];

sessions.fsKidsTeens = [sessions.fsKids; sessions.fsTeens];
sessions.kidsTeensAges = cat(2, sessions.kidsAges, sessions.teensAges);

sessions.fsAdults = {
    'CR24_scn181106_recon1121_v6'; 'CS22_scn190217_recon1121_v6'; ...
    'EM_scn201611_recon0723_v6'; 'es201810_v6'; ...
    'GB23_scn190117_recon1121_v6'; 'JEW23_scn181211_recon1121_v6'; ...
    'JP23_scn201708_recon0723_v6'; 'jw201810_v6'; ...
    'KM25_scn181204_recon1121_v6'; ...
    'MG_scn201708_recon0723_v6'; 'MJH25_scn180513_recon1121_v6'; ...
    'MN_scn201701_recon0723_v6'; 'MW23_scn190306_recon1121_v6'; ...
    'MZ23_scn190528_recon1121_v6'; 'NAV22_scn181218_recon1121_v6'; ...
    'NC24_scn190217_recon1121_v6'; 'sp201803_v6'; ...
    'ST25_scn190424_recon1121_v6'; 'th201810_v6'; ...
    'TL24_scn190428_recon0723_v6'; 'JG24_scn150426_recon1121_v6';...
    'MSH28_scn190109_recon1121_v6';'KG22_scn190128_recon1121_v6';...
    'VN26_scn190501_recon1121_v6';'DRS22_scn190506_recon1121_v6';...
    'MBA24_scn190130_recon1121_v6';'df201801_v6'};
sessions.adultsAges = [24, 22, 22, 28, 23, 23, 23, 28, 25, 29, 25, ...
    25, 23, 23, 22, 24, 30, 25, 32, 24, 27, 31, 26, 30, 22, 28, 25];

sessions.fsAll = [sessions.fsKidsTeens; sessions.fsAdults];
sessions.agesAll = cat(2, sessions.kidsTeensAges, sessions.adultsAges);

%% Initialize category (fLoc) sessions

sessions.catKidsTeens = {
    'ENK05_181201_time_03_1';
    'CLC06_190912_time_04_1';
    'ED07_190824_time_04_2';
    'ENK05_190203_time_03_2';
    'RJ09_181110_time_03_2';
    'INW06_191006_time_04_1';
    'RJ09_190810_time_04_1';
    'AOK07_190203_time_03_2';
    'CS11_181215_time_03_2';
    'GEJA09_190921_time_04_1';
    'MDT09_191027_time_03_2';
    'DAPA10_181201_time_03_2';
    'STM10_190903_time_03_2';
    'DAPA10_190921_time_04_1';
    'CGSA11_190910_time_04_1';
    'OS12_190724_time_06_1'
    };

sessions.catAdults = {
    'CS22_190217_time_03_1';
    'em_050317';
    'NAV22_181218_time_03_1';
    'GB23_190117_time_03_1';
    'JEW23_181211_time_03_1';
    'JP23_170111_time_02_1'; % JD25 tSeries is only 1 x 102
    'MW23_190306_time_03_1';
    'MZ190410';
    'CR24_181106_time_03_2';
    'NC24_190217_time_03_1';
    'TL24_190428_time_03_1';
    'KM25_181204_time_03_1';
    'mh102018';
    'MN181023';
    'ST25';
    'es103118';
    'jw103018';
    'mg_041817';
    'SP171101';
    'TH181012';
    'JG24_170109_time_04_1';
    'MSH28_181008_time_03_1';
    'KG22_190128_time_03_1';
    'VN26';
    'DRS22';
    'MBA24_190130_time_03_1';
    'df032518'
};

sessions.catTest = {'AOK07_190203_time_03_2';'CS22_190217_time_03_1';};

sessions.catAll = [sessions.catKidsTeens; sessions.catAdults];
