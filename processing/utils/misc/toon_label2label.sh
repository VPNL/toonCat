#!/bin/bash



# Subjects
sublist=('ENK05_scn191214_recon0920_v6'
'DAPA10_scn191123_recon0920_v6'
'CR24_scn181106_recon1121_v6'
'CS22_scn190217_recon1121_v6'
'EM_scn201611_recon0723_v6'
'es201810_v6'
'GB23_scn190117_recon1121_v6'
'JEW23_scn181211_recon1121_v6'
'JP23_scn201708_recon0723_v6'
'jw201810_v6'
'KGS_scn201708_recon0723_v6'
'KM25_scn181204_recon1121_v6'
'MG_scn201708_recon0723_v6'
'MJH25_scn180513_recon1121_v6'
'MN_scn201701_recon0723_v6'
'MW23_scn190306_recon1121_v6'
'MZ23_scn190528_recon1121_v6'
'NAV22_scn181218_recon1121_v6'
'NC24_scn190217_recon1121_v6'
'sp201803_v6'
'ST25_scn190424_recon1121_v6'
'th201810_v6'
'TL24_scn190428_recon0723_v6'
'JG24_scn150426_recon1121_v6'
'MSH28_scn190109_recon1121_v6'
'KG22_scn190128_recon1121_v6'
'VN26_scn190501_recon1121_v6'
'DRS22_scn190506_recon1121_v6'
'MBA24_scn190130_recon1121_v6'
'df201801_v6')

# Hemis
hemis=("rh" "lh")


# Labels LH
hemis=("lh")
# labels=("MPM_lh_mFus_adult_20thresh_contour.label"
# "MPM_lh_mOTS_adult_20thresh_contour.label"
# "MPM_lh_OTS_adult_20thresh_contour.label"
# "MPM_lh_pFus_adult_20thresh_contour.label"
# "MPM_lh_pOTS_adult_20thresh_contour.label"
# "MPM_lh_PPA_adult_20thresh_contour.label")
labels=("MPM_lh.FG1.label"
	"MPM_lh.FG2.label"
	"MPM_lh.FG3.label"
	"MPM_lh.FG4.label")

# Labels RH
hemis=("rh")
# labels=("MPM_rh_mFus_adult_20thresh_contour.label"
# "MPM_rh_OTS_adult_20thresh_contour.label"
# "MPM_rh_pFus_adult_20thresh_contour.label"
# "MPM_rh_PPA_adult_20thresh_contour.label")
labels=("MPM_rh.FG1.label"
	"MPM_rh.FG2.label"
	"MPM_rh.FG3.label"
	"MPM_rh.FG4.label")

# Set and define variables
SUBJECTS_DIR=/oak/stanford/groups/kalanit/biac2/kgs/anatomy/freesurferRecon/Kids_AcrossYears


#Screenshot
for sub in "${sublist[@]}";do
	echo $sub
	for h in "${hemis[@]}";do
		for label in "${labels[@]}";do
		    # mri_label2label --srcsubject fsaverage \
		    #            --trgsubject "${sub}" \
		    #            --srclabel "${SUBJECTS_DIR}/fsaverage/label/rosenke_cyto_atlas/${label}" \
		    #            --trglabel "${SUBJECTS_DIR}/${sub}/label/${label}" \
		    #            --hemi ${h} \
		    #            --regmethod surface
		    src_label="${SUBJECTS_DIR}/fsaverage/label/rosenke_cyto_atlas/${label}"
		    trg_label="${SUBJECTS_DIR}/${sub}/label/${label}"

		    # Perform the label transformation
		    mri_label2label --srcsubject fsaverage \
		                    --trgsubject "${sub}" \
		                    --srclabel "${src_label}" \
		                    --trglabel "${trg_label}" \
		                    --hemi ${h} \
		                    --regmethod surface

		    # Rename the target label to remove 'MPM_' prefix
		    new_trg_label="${trg_label/MPM_/}"
		    mv "${trg_label}" "${new_trg_label}"

	    done
    done

done

