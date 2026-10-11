#!/usr/bin/env python3
"""
Recompute fixation spread and saccade counts for the Toonotopy eyetracking data
using the FUNCTIONAL blink-removed sample files (matfiles/FuncBlinksRemoved/*.mat),
which null the partial-occlusion samples flanking each blink that EyeLink's own
blink events miss. Sample columns are [time_ms, x_deg, y_deg, pupil]; ~250 Hz.

Outputs:
  - toonCat_eyetracking_FuncBlinkRemoved.csv   (per-subject metrics + QC)
  - prints teens-vs-adults t-tests on saccade rate and fixation spread
Saccade detection: velocity-threshold detector on the cleaned samples
(30 deg/s, >=8 ms, amplitude thresholds 1 and 3 deg), gaps at NaN so blinks
are never bridged. Per-run QC flags tracking-loss runs (fixation spread > 5 deg).
"""
import scipy.io, scipy.stats, numpy as np, glob, os, csv
np.seterr(all='ignore')

TOON = "/Volumes/kalanit/biac2/kgs/projects/Kids_AcrossYears/Behavior/Toonotopy"
OUT_CSV = os.path.expanduser(
    "~/Documents/projects/toonCat/analysis/data/toonCat_eyetracking_FuncBlinkRemoved.csv")

# manuscript subjects that have FuncBlinksRemoved data (server folder name)
SUBJECTS = {
    "teens":  ["AOK07","CGSA11","CLC06","ENK05","GEJA09","INW06","MDT09","RJ09","STM10"],
    "adults": ["JG24","JP23","MBA24","MW23","MZ23","NC24","ST25","TL24","VN26"],
}
GROUP_DIR = {"teens": "Kids", "adults": "Adults"}

VTHRESH   = 30.0    # deg/s saccade velocity threshold
MIN_DUR   = 8       # ms minimum saccade duration
QC_SPREAD = 5.0     # deg; a run with fixation spread above this = tracking loss

def find_dir(group, subj):
    hits = sorted(glob.glob(f"{TOON}/{GROUP_DIR[group]}/{subj}*/*/eyetracking/matfiles/FuncBlinksRemoved"))
    hits = [h for h in hits if glob.glob(f"{h}/*.mat")]
    return hits[0] if hits else None

def load_run(f):
    m = scipy.io.loadmat(f, squeeze_me=True)
    k = [x for x in m if not x.startswith("__")][0]
    a = np.atleast_2d(m[k]).astype(float)
    return a[:, 0], a[:, 1], a[:, 2]      # t(ms), x(deg), y(deg)

def detect_saccades(t, x, y, min_amp):
    dt = np.nanmedian(np.diff(t)) / 1000.0
    vx = np.gradient(x) / dt; vy = np.gradient(y) / dt
    v = np.hypot(vx, vy)
    above = v > VTHRESH
    above[np.isnan(v)] = False
    edges = np.where(np.diff(np.concatenate(([0], above.view(np.int8), [0]))) != 0)[0]
    starts, ends = edges[0::2], edges[1::2]
    min_samps = max(1, int(round(MIN_DUR / 1000.0 / dt)))
    n = 0
    for s, e in zip(starts, ends):
        if e - s < min_samps:
            continue
        sx, sy = x[s:e], y[s:e]
        if np.isnan(sx).any() or np.isnan(sy).any():   # never bridge a blink gap
            continue
        if np.hypot(x[e-1]-x[s], y[e-1]-y[s]) >= min_amp:
            n += 1
    return n

rows = []
for group, subs in SUBJECTS.items():
    for subj in subs:
        d = find_dir(group, subj)
        if d is None:
            print(f"WARNING: no FuncBlinksRemoved for {group}/{subj}"); continue
        files = sorted(glob.glob(f"{d}/*.mat"))
        rec_min = 0.0
        n1 = n2 = n3 = n1_qc = n2_qc = n3_qc = 0
        rec_min_qc = 0.0
        allx, ally = [], []
        bad_runs = []
        for f in files:
            t, x, y = load_run(f)
            dur = (np.nanmax(t) - np.nanmin(t)) / 60000.0
            good = ~np.isnan(x)
            spread = np.sqrt(np.nanvar(x[good]) + np.nanvar(y[good])) if good.sum() > 10 else np.nan
            c1, c2, c3 = detect_saccades(t, x, y, 1.0), detect_saccades(t, x, y, 2.0), detect_saccades(t, x, y, 3.0)
            rec_min += dur; n1 += c1; n2 += c2; n3 += c3
            run_ok = np.isfinite(spread) and spread <= QC_SPREAD
            if run_ok:
                rec_min_qc += dur; n1_qc += c1; n2_qc += c2; n3_qc += c3
                allx.append(x[good]); ally.append(y[good])
            else:
                bad_runs.append(os.path.basename(f))
        X = np.concatenate(allx) if allx else np.array([])
        Y = np.concatenate(ally) if ally else np.array([])
        spread_all = np.sqrt(np.var(X) + np.var(Y)) if X.size > 10 else np.nan
        rows.append(dict(
            group=group, subject=subj, n_runs=len(files), n_runs_bad=len(bad_runs),
            rec_min=round(rec_min, 2), rec_min_qc=round(rec_min_qc, 2),
            fix_spread_deg=round(spread_all, 3) if np.isfinite(spread_all) else "",
            n_sacc_1deg=n1_qc, n_sacc_2deg=n2_qc, n_sacc_3deg=n3_qc,
            sacc_rate_1deg=round(n1_qc / rec_min_qc, 3) if rec_min_qc > 0 else "",
            sacc_rate_2deg=round(n2_qc / rec_min_qc, 3) if rec_min_qc > 0 else "",
            sacc_rate_3deg=round(n3_qc / rec_min_qc, 3) if rec_min_qc > 0 else "",
            n_sacc_1deg_allruns=n1, n_sacc_3deg_allruns=n3,
            bad_runs=";".join(bad_runs)))

# write CSV
cols = ["group","subject","n_runs","n_runs_bad","rec_min","rec_min_qc","fix_spread_deg",
        "n_sacc_1deg","n_sacc_2deg","n_sacc_3deg","sacc_rate_1deg","sacc_rate_2deg","sacc_rate_3deg",
        "n_sacc_1deg_allruns","n_sacc_3deg_allruns","bad_runs"]
with open(OUT_CSV, "w", newline="") as fh:
    w = csv.DictWriter(fh, fieldnames=cols); w.writeheader()
    for r in rows: w.writerow(r)
print(f"\nwrote {OUT_CSV}\n")

# print table
hdr = f"{'grp':6} {'subj':8} {'runs':>4} {'bad':>3} {'min':>6} {'spread':>7} {'sac1/m':>7} {'sac3/m':>7}"
print(hdr); print("-"*len(hdr))
for r in rows:
    print(f"{r['group']:6} {r['subject']:8} {r['n_runs']:>4} {r['n_runs_bad']:>3} "
          f"{r['rec_min_qc']:>6} {str(r['fix_spread_deg']):>7} "
          f"{str(r['sacc_rate_1deg']):>7} {str(r['sacc_rate_3deg']):>7}")

# t-tests (QC-filtered), teens vs adults
def col(group, key):
    return np.array([r[key] for r in rows if r['group']==group and r[key] != ""], float)
print("\n=== teens vs adults (QC-filtered runs) ===")
for key, lab in [("sacc_rate_1deg","saccade rate >=1deg /min"),
                 ("sacc_rate_2deg","saccade rate >=2deg /min"),
                 ("sacc_rate_3deg","saccade rate >=3deg /min"),
                 ("fix_spread_deg","fixation spread (deg)")]:
    a, b = col("teens", key), col("adults", key)
    t, p = scipy.stats.ttest_ind(a, b, equal_var=False, nan_policy='omit')
    print(f"{lab:30}  teens {a.mean():6.2f}+/-{a.std(ddof=1):4.2f}   "
          f"adults {b.mean():6.2f}+/-{b.std(ddof=1):4.2f}   t={t:5.2f}  p={p:.3f}")
