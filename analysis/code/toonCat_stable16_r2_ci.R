# Supplementary Table 16: bootstrapped KS-tests of pRF model fit (R2), adolescents vs adults.
# Matches the format of S. Table 5 (per hemisphere: Mean KS (D), 95% CI, Bootstrap p).
# The 95% CI is a bootstrap CI on the KS statistic D (resampling subjects; n = 10,000),
# since the R2 data are per-subject. Observed D and bootstrap p are read from the KS results CSV.
suppressMessages({library(dplyr); library(gt)})

data_dir <- "~/Documents/projects/toonCat/analysis/data"
out_dir  <- "~/Documents/projects/toonCat/analysis/results/revision"
rois <- c("pOTS_words","mOTS_words","OTS_bodies","IOG_faces","pFus_faces","mFus_faces",
          "CoS_places","LOS_limbs","ITG_limbs","MTG_limbs","pSTS_faces","MOG_places","IPS_places")

r2 <- read.csv(file.path(data_dir,"toonCat_r2_ve0_ALL.csv")) %>%
  filter(roi %in% rois, !is.na(r2)) %>%
  mutate(grp = ifelse(grepl("adult", tolower(group)), "Adults", "adolescents"))
res <- read.csv(file.path(out_dir,"toonCat_kstest_r2_results.csv")) %>% select(roi, hemi, ks_stat, p_boot)

set.seed(1); B <- 10000
boot <- r2 %>% group_by(roi, hemi) %>% group_modify(function(g, k){
  a <- g$r2[g$grp == "adolescents"]; b <- g$r2[g$grp == "Adults"]
  if (length(a) < 3 || length(b) < 3) return(tibble(lo = NA_real_, hi = NA_real_))
  Db <- replicate(B, tryCatch(as.numeric(suppressWarnings(
          ks.test(sample(a, replace = TRUE), sample(b, replace = TRUE))$statistic)),
          error = function(e) NA_real_))
  tibble(lo = quantile(Db, .025, na.rm = TRUE), hi = quantile(Db, .975, na.rm = TRUE))
}) %>% ungroup() %>% left_join(res, by = c("roi","hemi")) %>%
  mutate(base_roi = sub("_(faces|bodies|places|words|limbs).*", "", roi, perl = TRUE),
         cat_tok  = tolower(sub(".*_(faces|bodies|places|words|limbs).*", "\\1", roi, perl = TRUE)),
         label    = paste0(base_roi, " - ", cat_tok),
         D  = sprintf("%.3f", ks_stat),
         CI = sprintf("(%.2f, %.2f)", lo, hi),
         p  = paste0(formatC(p_boot, format = "e", digits = 2), ifelse(p_boot < 0.05, " ✱", "")))

roi_order <- c("pOTS - words","mOTS - words","OTS - bodies","IOG - faces","pFus - faces",
               "mFus - faces","CoS - places","LOS - limbs","ITG - limbs","MTG - limbs",
               "pSTS - faces","MOG - places","IPS - places")
lh <- boot %>% filter(hemi == "lh") %>% transmute(label, LH_D = D, LH_CI = CI, LH_p = p)
rh <- boot %>% filter(hemi == "rh") %>% transmute(label, RH_D = D, RH_CI = CI, RH_p = p)

tab <- full_join(lh, rh, by = "label") %>%
  mutate(label = factor(label, levels = roi_order)) %>% arrange(label) %>%
  gt(rowname_col = "label") %>%
  tab_spanner("Left hemisphere",  c(LH_D, LH_CI, LH_p)) %>%
  tab_spanner("Right hemisphere", c(RH_D, RH_CI, RH_p)) %>%
  cols_label(LH_D = "Mean KS (D)", LH_CI = "95% CI", LH_p = "Bootstrap p",
             RH_D = "Mean KS (D)", RH_CI = "95% CI", RH_p = "Bootstrap p", label = "ROI - category") %>%
  cols_align("center", columns = everything()) %>%
  tab_style(style = cell_text(align = "center"), locations = cells_stub()) %>%
  tab_options(table.font.names = c("Helvetica","Arial"), table.font.size = px(12),
    column_labels.font.weight = "bold", data_row.padding = px(4),
    column_labels.border.top.color = "black", column_labels.border.bottom.color = "black") %>%
  tab_source_note(md("✱ *p* < 0.05 (uncorrected); no region survives correction for multiple comparisons.")) %>%
  tab_options(source_notes.font.size = px(11))

gtsave(tab, file.path(out_dir, "S.Table16_KStest_r2.png"), vwidth = 1800, vheight = 1800)
gtsave(tab, file.path(out_dir, "S.Table16_KStest_r2.pdf"))
cat("wrote S.Table16_KStest_r2.png/.pdf to", out_dir, "\n")
