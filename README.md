# README.md

## Description
This folder contains all the code necessary for processing and analyzing the data, computing statistics, and making individual figure panels for the `toonCat` project (Yao et al., 2025). 

## Table of Contents
- [Dependencies](#dependencies)
- [Folder Structure](#folder-structure)
- [Usage](#usage)

## Dependencies
Code should run on your local machine assuming the following dependencies
### Processing Pipeline
- MATLAB 2023a
- Freesurfer v6.0
- vistasoft (https://github.com/vistalab/vistasoft)
- knkutils (https://github.com/kendrickkay/knkutils)
- alignvolumedata (https://github.com/kendrickkay/alignvolumedata)

### Analysis Pipeline
- R >= 4.2.2
- tidyverse
- dplyr
- ggplot2
- lme4
- lmerTest
- emmeans
- broom.mixed
- janitor
- extrafont
- kableExtra
- sjPlot
- broom
- rlang
- fs
- gt
- ggh4x
- patchwork
- purrr
- R.matlab

### Eye-tracking Analysis
- Python 3 with numpy, scipy, matplotlib

## Folder Structure
`processing`: Includes numbered MATLAB scripts used to process the structural and functional data.
- `toonCat_step1` - `toonCat_step3`: pRF analysis; these scripts run the pRF model (step1), setup retinopic map drawing (step2), and extract retinotopic data from each individual and prepare it for analysis (step3). Also outputs center and coverage panels for Fig 3A and Fig 4A&B.
- `toonCat_step4` - `toonCat_step6`: category-selectivity analysis; these scripts run fLoC analysis (step4), setup category ROI drawing (step5), and extract category data from each individual and prepare it for analysis (step6)
- `utils`: Contains functions for each of the steps, organized via subdirectories `step#/`

`analysis`: Includes code used to analyze data extracted from the `processing` code, perform LMMs, and generate output figures.
- `code`: Contains R and R markdown files used to generate main figures and supplementary figures.
  - `toonCat_fig3.Rmd`, `toonCat_fig4.Rmd`, `toonCat_fig5_ROISize.Rmd`, `toonCat_fig6.Rmd`: main figure panels and post-hoc tests
  - `toonCat_supplementaryTables.Rmd`, `toonCat_SI_FiguresTables.Rmd`, `toonCat_supplementaryFigures.Rmd`: supplementary tables and figures
  - `toonCat_noiseAnalyses_revision.Rmd`: data-quality analyses added in revision (task performance, eye tracking, head motion, tSNR, pRF model fit R²)
  - `toonCat_subsampled100vox.Rmd`: reproduction of pRF and coverage analyses with ROIs subsampled to 100 voxels (Supplementary Table 15)
  - `toonCat_stable16_r2_ci.R`: bootstrapped KS-tests of pRF R² (Supplementary Table 16)
  - `toonCat_saccades_FuncBlinkRemoved.py`, `toonCat_saccades_plots.py`: fixation spread and saccade rate from eye-tracking data
- `data`: Contains processed data used for figure generation and statistics
- `figures_tables`: Contains `main` figure outputs and `supplement` figures outputes and tables. Tables contain full statistical outputs in .png and .csv formats.

## Usage
To regenerate all data, install all `processing` dependencies, run code in `processing`,and then run code in `analysis`. To rerun statistics, use processed data and only run `analysis` code; setup/dependency installation is included in pipeline (`toonCat_analysisSetup.R`). 


