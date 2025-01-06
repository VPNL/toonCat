######## toonCat_analysisSetup.R ##################################################################################

# Libaries, data, plot setup, data wrangling for the toonCat manuscript statistical analyses in R 
# Used in toonCat_mainFigures.Rmd and toonCat_supplementaryFiguresTables.RmD
# See toonCat_figures_new.Rmd for original code in case someting is buggy

# JKY Dec 2024
###################################################################################################################

# Load libraries
library(tidyverse)
library(dplyr)
library(ggplot2)
library(lme4)
library(emmeans)
library(janitor)
library(extrafont)
library(kableExtra)
library(sjPlot)
library(broom)
library(rlang)
library(fs)

# DATA ############################################################################################################
# Load data
## Age info
df.ages = read_csv("./data/subject_ages_mrVista.csv")
df.ages_catSelect = read_csv("./data/subject_ages_category.csv")

## pRF size v eccentricity (slopes, intercepts)
sizeEcc_ventral = read.csv("./data/pRF_SizeEcc_toonCat_KidsTeensAdults_toonROIs.csv")
sizeEcc_lateral = read.csv("./data/pRF_SizeEcc_toonCat_lateral_JC_KidsTeensAdults_toonROIs.csv")
sizeEcc = bind_rows(sizeEcc_lateral, sizeEcc_ventral)

## pRF centers
centers_lateral = read.csv("./data/pRFCenters_KidsTeensAdults_lateralROIs_pSTS_MTG_AdultAvg.csv")
centers_ventral = read.csv("./data/pRFCenters_KidsTeensAdults_ret_catROIs.csv")
centers = bind_rows(centers_lateral, centers_ventral)

## pRF coverage
CoV = read.csv("./data/pRF_CoVCenters_KidsTeensAdults_allROIs.csv")

## Category selectivity
category = read.csv("./data/catSelectivity_3Runs_diskROIs_10mm.csv") #original output
df.category = read.csv("./data/categorySelectivity.csv") #wrangled output

## ROI size
ROIsize_lateral = read.csv("./data/pRFCoVCenters_KidsTeensAdults_lateralROIs_zerosSize.csv")
ROIsize_ventral = read.csv("./data/pRFCoVCenters_KidsTeensAdults_ret_catROIs.csv")
ROIsize = bind_rows(ROIsize_lateral, ROIsize_ventral)

# PLOT/DF VARIABLES ###############################################################################################
# Global plot setup
theme_set(theme_classic())
fonts()

# Subject names (centers, coverage, size dfs)
old_names <- c(
  'ENK05/ENK05_190317_19993_time_03_1',
  'CLC06/CLC06_190912_21275_time_04_1',
  'ED07/ED07_190914_21286_time_04_1',
  'ENK05/ENK05_191208_21930_time_04_1', 
  'INW06/INW06_191103_21656_time_04_1',
  'RJ09/RJ09_190914_21289_time_04_1',
  'AOK07/AOK07_191207_21927_time_04_1',
  'CS11/CS11_190203_19652_time_03_1',
  'GEJA09/GEJA09_190921_21343_time_04_1',
  'MDT09/MDT09_191006_21450_time_03_1',
  'DAPA10/DAPA10_190112_19476_time_03_1',
  'STM10/STM10_190903_21220_time_03_1',
  'DAPA10/DAPA10_191012_21490_time_04_1',
  'CGSA11/CGSA11_190921_21340_time_04_1',  
  'OS12/OS12_190725_20947_time_06_1')
adolescents <- sub('.*/', '', old_names)
Adults <- c(    "CS22",
                "EM",
                "NAV22",
                "GB23",
                "JEW23",
                "JP23",
                "MW23",
                "MZ23",
                "CR24",
                "NC24",
                "TL24",
                "KM25",
                "MJH25",
                "MN",
                "ST25",
                "ES",
                "JW",
                "MG",
                "SP",
                "TH",
                "JG24",
                "MSH28",
                "KG22",
                "VN26",
                "DRS22",
                "MBA24",
                "DF")

# Subject names (category selectivity)
catSelect_adolescents <- c(
  'ENK05_181201_time_03_1',
  'CLC06_190912_time_04_1',
  'ED07_190824_time_04_2',
  'ENK05_190203_time_03_2',
  'INW06_191006_time_04_1',
  'RJ09_190810_time_04_1',
  'AOK07_190203_time_03_2',
  'CS11_181215_time_03_2',
  'GEJA09_190921_time_04_1',
  'MDT09_191027_time_03_2',
  'DAPA10_181201_time_03_2',
  'STM10_190903_time_03_2',
  'DAPA10_190921_time_04_1',
  'CGSA11_190910_time_04_1',
  'OS12_190724_time_06_1')
catSelect_Adults <- c(    "CS22_190217_time_03_1",
                          "050317_em",
                          "NAV22_181218_time_03_1",
                          "GB23_190117_time_03_1",
                          "JEW23_181211_time_03_1",
                          "JP25_01112017",
                          "MW23_190306_time_03_1",
                          "MZ190410",
                          "CR24_181106_time_03_2",
                          "NC24_190217_time_03_1",
                          "TL24_190428_time_03_1",
                          "KM25_181204_time_03_1",
                          "mh102018",
                          "MN181023",
                          "ST25",
                          "es103118",
                          "jw103018",
                          "041817_mg",
                          "SP171101",
                          "TH181012",
                          "JG24_170109_time_04_1",
                          "MSH28_181008_time_03_1",
                          "KG22_190128_time_03_1",
                          "VN26",
                          "DRS22",
                          "MBA24_190130_time_03_1",
                          "df032518")

# Subject names matching for category selectivity and FWHM/pRF size
cat_subs <- data.frame(subs = c(adolescents,Adults))
size_subs <- data.frame(subs = c(catSelect_adolescents, catSelect_Adults))
mapping <- data.frame(old_subs = cat_subs$subs, new_subs = size_subs$subs)

# ROI orders + colors
## All
custom_colors_all <- c("#5A1547", "#92053D", "#FFAE08", "#848D00", "#0E5A2E","#990000","#FF0000", "#ff2d59","#000066","#66CCFF","#E4CD04","#008000", "white","#FDA60E","#E9C968","#F7B808","#fe5940","white", "#52b06e","#588159")
roi_order_all <- c("V1", "V2", "V3", "hV4", "VO","IOG_faces", "pFus_faces", "mFus_faces", "pOTS_words", "mOTS_words","OTS_bodies", "CoS_places", "blank", "LOS_limbs","ITG_limbs", "MTG_limbs","pSTS_faces", "blank1","MOG_places","IPS_places")

## Retinotopy
roi_order_ret <- c("V1", "V2", "V3", "hV4", "VO")
custom_colors_ret <- c("#5A1547", "#92053D", "#FFAE08", "#848D00", "#0E5A2E")

## Category
roi_order_cat <- c("IOG_faces", "pFus_faces", "mFus_faces", "pOTS_words", "mOTS_words","OTS_bodies","CoS_places","blank","LOS_limbs","ITG_limbs", "MTG_limbs","pSTS_faces","blank1","MOG_places","IPS_places")
custom_colors_cat <- c("#990000","#FF0000","#ff2d59","#000066","#66CCFF","#E4CD04","#008000","white","#FDA60E","#E9C968","#F7B808","#fe5940","white","#52b06e","#588159")

## Ventral Stream
ventral_cat <- c("IOG_faces","pFus_faces", "mFus_faces", "pOTS_words", "mOTS_words","OTS_bodies", "CoS_places")
roi_order_cat_vent <- c("IOG_faces", "pFus_faces", "mFus_faces", "pOTS_words", "mOTS_words","OTS_bodies", "CoS_places","blank")
custom_colors_cat_vent <- c("#990000","#FF0000", "#ff2d59","#000066","#66CCFF","#E4CD04","#008000","white")

## Dorsal-Lateral Stream
lateral_dorsal_cat <- c("pSTS_faces", "LOS_limbs","ITG_limbs", "MTG_limbs","blank1","MOG_places","IPS_places")
lateral_cat <- c("pSTS_faces", "LOS_limbs","ITG_limbs", "MTG_limbs")
dorsal_cat <- c("MOG_places","IPS_places")
roi_order_cat_lat <- c("LOS_limbs","ITG_limbs", "MTG_limbs","pSTS_faces","blank1","MOG_places","IPS_places")
custom_colors_cat_lat <- c("#FDA60E","#E9C968","#F7B808","#fe5940","white","#52b06e","#588159")

## Category ROIs
roi_order_face <- c("IOG_faces", "pFus_faces", "mFus_faces","pSTS_faces")
custom_colors_face <- c("#990000","#FF0000", "#ff2d59","#fe5940")
roi_order_bodies <- c("OTS_bodies","LOS_limbs","ITG_limbs", "MTG_limbs")
custom_colors_bodies <- c("#E4CD04","#FDA60E","#E9C968","#F7B808")
roi_order_place <- c("CoS_places","MOG_places","IPS_places")
custom_colors_place <- c("#008000","#A2B18A","#588159")
roi_order_word <- c("pOTS_words", "mOTS_words")

roi_colors <- setNames(custom_colors_cat, roi_order_cat)

# DATA WRANGLING ##################################################################################################
# pRF size v eccentricity
df.sizeEcc = sizeEcc %>%
  mutate(sub = sub('.*/', '', sub),
         ROI = gsub('_toon', '', ROI),
         ROI = gsub('_JC', '', ROI),
         group = ifelse(sub %in% adolescents, "adolescents", "Adults"),
         ROItype = case_when(
           ROI %in% roi_order_ret ~ "retinotopy",
           ROI %in% roi_order_cat ~ "category"),
         ROI = factor(ROI, levels = roi_order_all),
         group = factor(group, levels = c("adolescents", "Adults"))) %>%
  left_join(df.ages, by = "sub") %>%
  filter(age < 35,
         age >= 10)

# pRF centers
df.centers = centers %>%
  mutate(sub = sub('.*/', '', sub),
         group = ifelse(sub %in% adolescents, "adolescents", "Adults"),
         centerX = CenterXs,
         centerY = CenterYs,
         centerR = sqrt(centerX^2 + centerY^2),
         ROItype = case_when(
           ROI %in% roi_order_ret ~ "retinotopy",
           ROI %in% roi_order_cat ~ "category"),
         ROI = factor(ROI, levels = roi_order_all),
         hemi = factor(hemi, levels = c("lh", "mh", "rh", "zh")),
         group = factor(group, levels = c("adolescents", "Adults"))) %>%
  left_join(df.ages, by = "sub") %>%
  filter(age < 35,
         age >= 10,
         ROItype != 'kubotaMPM',
         ROI != 'PHC',
         !(ROI == 'mOTS_words' & hemi == 'rh'),
         hemi != 'mh')

# pRF coverage
df.CoV = CoV %>%
  mutate(sub = sub('.*/', '', subject),
         group = ifelse(sub %in% adolescents, "adolescents", "Adults"),
         CoM_r = sqrt(CoM_x^2 + CoM_y^2),
         ROItype = case_when(
           ROI %in% roi_order_ret ~ "retinotopy",
           ROI %in% roi_order_cat ~ "category"),
         ROI = factor(ROI, levels = roi_order_all),
         hemi = factor(hemi, levels = c("lh", "mh", "rh", "zh")),
         group = factor(group, levels = c("adolescents", "Adults"))) %>%
  left_join(df.ages, by = "sub") %>%
  filter(age < 35,
         age >= 10,
         ROItype != 'kubotaMPM',
         ROI != 'PHC',
         !(ROI == 'mOTS_words' & hemi == 'rh'),
         hemi != 'mh')

# Retinotopy data
## pRF sizeEcc
df.sizeEcc_ret = df.sizeEcc %>%
  filter(ROItype == 'retinotopy',
         ROI %in% c('V1', 'V2', 'V3')) %>%
  mutate(ROI = factor(ROI, levels = roi_order_ret))
## pRF centers
df.centers_ret = df.centers %>%
  filter(ROItype == 'retinotopy') %>%
  mutate(ROI = factor(ROI, levels = roi_order_ret))
## pRF coverage
df.CoV_ret = df.CoV %>%
  filter(ROItype == 'retinotopy') %>%
  mutate(ROI = factor(ROI, levels = roi_order_ret))

# Category data
## pRF centers - ventral,dorsal,lateral
df.centers_cat = df.centers %>%
  filter(ROItype == 'category')%>%
  mutate(ROI = factor(ROI, levels = roi_order_cat),
         stream = case_when(
           ROI %in% ventral_cat ~ "ventral",
           ROI %in% lateral_cat ~ "lateral",
           ROI %in% dorsal_cat ~ "dorsal"),
         category = case_when(
           ROI %in% roi_order_face ~ "face",
           ROI %in% roi_order_word ~ "word",
           ROI %in% roi_order_bodies ~ "body",
           ROI %in% roi_order_place ~ "place"))
## pRF centers - ventral,dorsal-lateral
df.centers_cat_latdors = df.centers %>%
  filter(ROItype == 'category')%>%
  mutate(ROI = factor(ROI, levels = roi_order_cat),
         stream = case_when(
           ROI %in% ventral_cat ~ "ventral",
           ROI %in% lateral_dorsal_cat ~ "lateraldorsal"),
         category = case_when(
           ROI %in% roi_order_face ~ "face",
           ROI %in% roi_order_word ~ "word",
           ROI %in% roi_order_bodies ~ "body",
           ROI %in% roi_order_place ~ "place"))
## pRF coverage - ventral,dorsal,lateral
df.CoV_cat = df.CoV %>%
  filter(ROItype == 'category')%>%
  mutate(ROI = factor(ROI, levels = roi_order_cat),
         stream = case_when(
           ROI %in% ventral_cat ~ "ventral",
           ROI %in% lateral_cat ~ "lateral",
           ROI %in% dorsal_cat ~ "dorsal"),
         category = case_when(
           ROI %in% roi_order_face ~ "face",
           ROI %in% roi_order_word ~ "word",
           ROI %in% roi_order_bodies ~ "body",
           ROI %in% roi_order_place ~ "place"))
## pRF coverage - ventral,dorsal-lateral
df.CoV_cat_latdors = df.CoV %>%
  filter(ROItype == 'category')%>%
  mutate(ROI = factor(ROI, levels = roi_order_cat),
         stream = case_when(
           ROI %in% ventral_cat ~ "ventral",
           ROI %in% lateral_dorsal_cat ~ "lateraldorsal"),
         category = case_when(
           ROI %in% roi_order_face ~ "face",
           ROI %in% roi_order_word ~ "word",
           ROI %in% roi_order_bodies ~ "body",
           ROI %in% roi_order_place ~ "place"))

# Category selectivity
df.cat = category %>%
  filter(!(ROI %in% c('pSTS_faces_toon_JC_10mm','MTG_limbs_toon_JC_10mm'))) %>%
  mutate(sub = Session,
         ROI = sub('(_toon.*|_adultAvg.*)', '', ROI),
         group = ifelse(sub %in% catSelect_adolescents, "adolescents", "Adults"),
         ROItype = case_when(
           ROI %in% roi_order_ret ~ "retinotopy",
           ROI %in% roi_order_cat ~ "category"),
         ROI = factor(ROI, levels = roi_order_all),
         hemi = factor(Hemi, levels = c("lh", "mh", "rh", "zh")),
         group = factor(group, levels = c("adolescents", "Adults")),
         ROIcategory = case_when(
           ROI %in% c('IOG_faces', 'pFus_faces', 'mFus_faces', 'pSTS_faces') ~ "face",
           ROI %in% c('OTS_bodies', "LOS_limbs","ITG_limbs", "MTG_limbs") ~ "bodies",
           ROI %in% c('CoS_places', 'MOG_places', 'IPS_places') ~ "place",
           ROI %in% c('pOTS_words', 'mOTS_words') ~ "words",
           ROI %in% c('blank', 'blank1') ~ "other"),
         region = case_when(
           ROI %in% roi_order_cat_vent ~ "ventral",
           ROI %in% c("LOS_limbs","ITG_limbs", "MTG_limbs","pSTS_faces") ~ "lateral",
           ROI %in% c("MOG_places","IPS_places") ~ "dorsal")) %>%
  select(-contains(c('AdultFaces', 'ChildFaces', 'NoHeadBody', 'Limbs', 'Cars', 'Guitars', 'Corridors', 'Houses', 'Chars', 'Number'))) %>%
  pivot_longer(cols = matches("nr|mean"), names_to = "metric", values_to = "meanT") %>%
  separate(metric, into = c("type", "catSelectivity"), sep = "(?<=nr|mean)(?=[A-Z])",) %>%
  filter(type != "nr") %>%
  #pivot_wider(names_from = type, values_from = meanT) %>%
  select(-c("Session")) %>%
  filter((ROIcategory == "face" & catSelectivity == "Faces") |
           (ROIcategory == "words" & catSelectivity == "Words") |
           (ROIcategory == "bodies" & catSelectivity == "Bodies") |
           (ROIcategory == "place" & catSelectivity == "Places") |
           (ROIcategory == "other" & catSelectivity == "Places")) %>%
  left_join(df.ages_catSelect, by = "sub") %>%
  filter(age < 35,
         age >= 10,
         !(ROI == 'mOTS_words' & hemi == 'rh'))%>% 
  # filter(mean >= 0) %>%
  drop_na() %>%
  select(c('sub', 'group', 'age', 'hemi', 'ROI', 'ROItype', 'ROIcategory', 'region', 'meanT', 'catSelectivity' ))

df.category_latdors = df.category %>%
  mutate(ROI = factor(ROI, levels = roi_order_cat),
         group = ifelse(sub %in% catSelect_adolescents, "adolescents", "Adults"),
         stream = case_when(
           ROI %in% roi_order_cat_vent ~ "ventral",
           ROI %in% roi_order_cat_lat ~ "lateraldorsal"))

# ROI size
df.ROIsize = ROIsize %>%
  mutate(sub = sub('.*/', '', subject),
         group = ifelse(sub %in% adolescents, "adolescents", "Adults"),
         CoM_r = sqrt(CoM_x^2 + CoM_y^2),
         radius = sqrt((totalvox/3/3.14)),
         ROItype = case_when(
           ROI %in% roi_order_ret ~ "retinotopy",
           ROI %in% roi_order_cat ~ "category"),
         ROI = factor(ROI, levels = roi_order_all),
         hemi = factor(hemi, levels = c("lh", "mh", "rh", "zh")),
         group = factor(group, levels = c("adolescents", "Adults")),
         category = case_when(
           ROI %in% roi_order_face ~ "face",
           ROI %in% roi_order_bodies ~ "bodies",
           ROI %in% roi_order_place ~ "place",
           ROI %in% c('pOTS_words', 'mOTS_words') ~ "words")) %>%
  left_join(df.ages, by = "sub") %>%
  filter(age < 35,
         age >= 10,
         ROItype != 'kubotaMPM',
         ROI != 'PHC',
         !(ROI == 'mOTS_words' & hemi == 'rh'),
         hemi %in% c("lh", "rh"))
## ROI size retinotopic data
df.ROIsize_ret = df.ROIsize %>%
  filter(ROItype == 'retinotopy') %>%
  mutate(ROI = factor(ROI, levels = roi_order_ret))
## ROI size category data
df.ROIsize_cat = df.ROIsize %>%
  filter(ROItype == 'category')%>%
  mutate(ROI = factor(ROI, levels = roi_order_cat),
         region = case_when(
           ROI %in% ventral_cat ~ "ventral",
           ROI %in% lateral_cat ~ "lateral",
           ROI %in% dorsal_cat ~ "dorsal"))
## ROI size category data - lateraldorsal
df.ROIsize_cat_latdors = df.ROIsize_cat %>%
  mutate(ROI = factor(ROI, levels = roi_order_cat),
         group = ifelse(sub %in% adolescents, "adolescents", "Adults"),
         stream = case_when(
           ROI %in% roi_order_cat_vent ~ "ventral",
           ROI %in% roi_order_cat_lat ~ "lateraldorsal")) %>%
  select(c("sub", "hemi", "ROI", "category", "stream", "group", "age", "totalvox"))



# FWHM x Category Selectivity (mapping subjects from two df)
df.cat_latdors <- df.category_latdors %>%
  left_join(mapping, by = c("sub" = "new_subs")) %>%
  mutate(
    sub = old_subs  # Replace old values with new ones
  ) %>%
  select(-old_subs) %>% # Remove intermediate mapping column
  filter(hemi %in% c("lh", "rh"))

df.cat_FWHM = df.CoV_cat_latdors %>%
  select(c("sub", "group", "age", "hemi", "stream", "ROI", "fwhm")) %>%
  left_join(df.cat_latdors, by = c("sub", "group", "age", "hemi", "stream", "ROI"))

# df.cat_size = df.centers_cat_latdors %>%
#   select(c("sub", "group", "age", "hemi", "stream", "ROI", "size")) %>%
#   left_join(df.cat_latdors, by = c("sub", "group", "age", "hemi", "stream", "ROI"))


# SUMMARY TABLES ##################################################################################################
## pRF centers summary table (N)
centers_summary = df.centers %>%
  filter(ROItype != 'kubotaMPM',
         ROI != 'PHC',
         !(ROI == 'mOTS_words' & hemi == 'rh'),
         hemi != 'mh') %>%
  group_by(ROI, group, hemi) %>%
  summarise(Count = n(), 
            centerX = max(centerX),
            centerY = max(centerY),
            centerR = max(centerR),
            size = max(size)) %>%
  ungroup() %>%
  mutate(ROItype = case_when(
    ROI %in% roi_order_ret ~ "retinotopy",
    ROI %in% roi_order_cat ~ "category"))

## pRF coverage summary table (N)
CoV_summary = df.CoV %>%
  filter(ROItype != 'kubotaMPM',
         ROI != 'PHC',
         !(ROI == 'mOTS_words' & hemi == 'rh'),
         hemi != 'mh') %>%
  group_by(ROI, group, hemi) %>%
  summarise(Count = n(), 
            centerX = max(centerX),
            centerY = max(centerY),
            CoM_r = max(CoM_r),
            CoM_x = max(CoM_x),
            CoM_y = max(CoM_y),
            fwhm = max(fwhm)) %>%
  ungroup() %>%
  mutate(ROItype = case_when(
    ROI %in% roi_order_ret ~ "retinotopy",
    ROI %in% roi_order_cat ~ "category",
    ROI %in% c("pFus_kubotaMPM", "pOTS_kubotaMPM", "PPA_kubotaMPM", "mFus_kubotaMPM", "OTS_kubotaMPM","mOTS_kubotaMPM") ~ "kubotaMPM"))

# Retinotopic data summary tables (N)
## pRF centers
centers_summary_ret = centers_summary %>%
  filter(ROItype == 'retinotopy') %>%
  mutate(ROI = factor(ROI, levels = roi_order_ret))
## pRF coverage
CoV_summary_ret = CoV_summary %>%
  filter(ROItype == 'retinotopy') %>%
  mutate(ROI = factor(ROI, levels = roi_order_ret))

# Category data summary tables (N)
## pRF centers
centers_summary_cat = centers_summary %>%
  filter(ROItype == 'category') %>%
  mutate(ROI = factor(ROI, levels = roi_order_cat),
         stream = case_when(
           ROI %in% ventral_cat ~ "ventral",
           ROI %in% lateral_cat ~ "lateral",
           ROI %in% dorsal_cat ~ "dorsal",
           ROI %in% lateral_dorsal_cat ~ "lateraldorsal"))
## pRF coverage
CoV_summary_cat = CoV_summary %>%
  filter(ROItype == 'category')%>%
  mutate(ROI = factor(ROI, levels = roi_order_cat),
         stream = case_when(
           ROI %in% ventral_cat ~ "ventral",
           ROI %in% lateral_cat ~ "lateral",
           ROI %in% dorsal_cat ~ "dorsal",
           ROI %in% lateral_dorsal_cat ~ "lateraldorsal"))

# ROI size summary table (N)
ROIsize_summary = df.ROIsize %>%
  filter(ROItype != 'kubotaMPM',
         ROI != 'PHC',
         !(ROI == 'mOTS_words' & hemi == 'rh')) %>%
  group_by(ROI, group, hemi) %>%
  summarise(Count = n(), 
            centerX = max(centerX),
            centerY = max(centerY),
            CoM_x = max(CoM_x),
            CoM_y = max(CoM_y),
            CoM_r = max(CoM_r),
            fwhm = max(fwhm)) %>%
  ungroup() %>%
  mutate(ROItype = case_when(
    ROI %in% roi_order_ret ~ "retinotopy",
    ROI %in% roi_order_cat ~ "category"))
# Filter Summary for Retinotopic Data
ROIsize_summary_ret = ROIsize_summary %>%
  filter(ROItype == 'retinotopy') %>%
  mutate(ROI = factor(ROI, levels = roi_order_ret))
# Filter Summary for Category Data
ROIsize_summary_cat = ROIsize_summary %>%
  filter(ROItype == 'category')%>%
  mutate(ROI = factor(ROI, levels = roi_order_cat),
         region = case_when(
           ROI %in% ventral_cat ~ "ventral",
           ROI %in% lateral_cat ~ "lateral",
           ROI %in% dorsal_cat ~ "dorsal"))



