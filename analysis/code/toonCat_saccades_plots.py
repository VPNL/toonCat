#!/usr/bin/env python3
"""Gaze plots from FuncBlinksRemoved samples.
  - supplement figure (STM10, GEJA09): centered gaze scatter colored by time + x/y traces
  - montage: centered gaze scatter for all 18 subjects (manual fixation check)
"""
import scipy.io, numpy as np, glob, os
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
np.seterr(all='ignore')

TOON = "/Volumes/kalanit/biac2/kgs/projects/Kids_AcrossYears/Behavior/Toonotopy"
FIGDIR = os.path.expanduser("~/Documents/projects/toonCat/analysis/figures")
os.makedirs(FIGDIR, exist_ok=True)
GROUP_DIR = {"teens": "Kids", "adults": "Adults"}
SUBJECTS = {
    "teens":  ["AOK07","CGSA11","CLC06","ENK05","GEJA09","INW06","MDT09","RJ09","STM10"],
    "adults": ["JG24","JP23","MBA24","MW23","MZ23","NC24","ST25","TL24","VN26"],
}
QC_SPREAD = 5.0

def find_dir(group, subj):
    hits = sorted(glob.glob(f"{TOON}/{GROUP_DIR[group]}/{subj}*/*/eyetracking/matfiles/FuncBlinksRemoved"))
    hits = [h for h in hits if glob.glob(f"{h}/*.mat")]
    return hits[0] if hits else None

def load_subject(group, subj, qc=True):
    """Return centered x,y (deg) pooled across runs, plus per-run (t,x,y) list."""
    d = find_dir(group, subj)
    runs = []
    for f in sorted(glob.glob(f"{d}/*.mat")):
        m = scipy.io.loadmat(f, squeeze_me=True)
        k = [x for x in m if not x.startswith("__")][0]
        a = np.atleast_2d(m[k]).astype(float)
        t, x, y = a[:,0], a[:,1], a[:,2]
        good = ~np.isnan(x)
        spread = np.sqrt(np.nanvar(x[good]) + np.nanvar(y[good])) if good.sum() > 10 else np.inf
        if qc and spread > QC_SPREAD:
            continue
        runs.append((t, x, y))
    return runs

def centered_xy(runs):
    xs, ys = [], []
    for t, x, y in runs:
        g = ~np.isnan(x)
        xs.append(x[g] - np.nanmedian(x[g])); ys.append(y[g] - np.nanmedian(y[g]))
    if not xs: return np.array([]), np.array([])
    return np.concatenate(xs), np.concatenate(ys)

# ---- supplement figure: STM10 and GEJA09 ----
for subj, group in [("STM10","teens"), ("GEJA09","teens")]:
    runs = load_subject(group, subj)
    dx, dy = centered_xy(runs)
    spread = np.sqrt(np.var(dx) + np.var(dy))
    fig, ax = plt.subplots(1, 2, figsize=(11, 4.6))
    # left: gaze scatter colored by time within first run
    t, x, y = runs[0]; g = ~np.isnan(x)
    sc = ax[0].scatter(x[g]-np.nanmedian(x[g]), y[g]-np.nanmedian(y[g]),
                       c=t[g]/1000.0, s=3, cmap="viridis", alpha=0.5)
    th = np.linspace(0, 2*np.pi, 200)
    r95 = np.sqrt(5.991 * (np.var(dx)+np.var(dy))/2)   # 95% isotropic Gaussian
    ax[0].plot(r95*np.cos(th), r95*np.sin(th), 'r-', lw=1.5, label=f"95% ({r95:.2f}°)")
    ax[0].set_xlim(-4,4); ax[0].set_ylim(-4,4); ax[0].set_aspect('equal')
    ax[0].axhline(0, color='gray', lw=.5); ax[0].axvline(0, color='gray', lw=.5)
    ax[0].set_xlabel("horizontal (deg)"); ax[0].set_ylabel("vertical (deg)")
    ax[0].set_title(f"{subj}: gaze (run 1, colored by time)"); ax[0].legend(loc='upper right', fontsize=8)
    plt.colorbar(sc, ax=ax[0], label="time (s)", fraction=0.046)
    # right: x & y position over time, all QC runs concatenated
    off = 0;
    for t, x, y in runs:
        tt = (t - t.min())/1000.0 + off
        ax[1].plot(tt, x - np.nanmedian(x), lw=.4, color='C0')
        ax[1].plot(tt, y - np.nanmedian(y), lw=.4, color='C1')
        off = tt[-1] + 2
    ax[1].axhline(0, color='gray', lw=.5)
    ax[1].set_ylim(-6,6); ax[1].set_xlabel("time (s, runs concatenated)")
    ax[1].set_ylabel("position (deg)")
    ax[1].set_title(f"pooled fixation spread = {spread:.2f}°")
    ax[1].plot([],[],color='C0',label='horizontal'); ax[1].plot([],[],color='C1',label='vertical')
    ax[1].legend(loc='upper right', fontsize=8)
    fig.suptitle(f"{subj} ({group}) — functional blink removal", fontsize=13)
    fig.tight_layout()
    p = f"{FIGDIR}/eyetracking_supplement_{subj}.png"
    fig.savefig(p, dpi=150); plt.close(fig); print("wrote", p)

# ---- montage: all subjects ----
fig, axes = plt.subplots(3, 6, figsize=(16, 8.5))
order = [("teens",s) for s in SUBJECTS["teens"]] + [("adults",s) for s in SUBJECTS["adults"]]
for ax, (group, subj) in zip(axes.flat, order):
    runs = load_subject(group, subj)
    dx, dy = centered_xy(runs)
    if dx.size:
        spread = np.sqrt(np.var(dx)+np.var(dy))
        ax.hexbin(dx, dy, gridsize=40, extent=(-4,4,-4,4), cmap="magma", bins='log')
        ax.set_title(f"{subj} ({group[:1]})  σ={spread:.2f}°", fontsize=9)
    else:
        ax.set_title(f"{subj} ({group[:1]})  NO QC DATA", fontsize=9, color='red')
    ax.set_xlim(-4,4); ax.set_ylim(-4,4); ax.set_aspect('equal')
    ax.set_xticks([]); ax.set_yticks([])
for ax in axes.flat[len(order):]:
    ax.axis('off')
fig.suptitle("Toonotopy fixation distributions (FuncBlinksRemoved, QC-passed runs) — centered, deg", fontsize=13)
fig.tight_layout()
p = f"{FIGDIR}/eyetracking_montage_allSubjects.png"
fig.savefig(p, dpi=150); plt.close(fig); print("wrote", p)
