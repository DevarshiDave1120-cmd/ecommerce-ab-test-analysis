# CLAUDE.md

## Project goal
Portfolio project: end-to-end analysis of a public e-commerce landing-page A/B test
(Kaggle/Udacity `ab_data.csv`, ~294K rows: user_id, timestamp, group, landing_page, converted).

Pipeline: raw CSV → **BigQuery** (`raw.ab_data`) → **dbt** (staging → intermediate → marts, with tests)
→ **Python** stats (SRM check, two-proportion z-test, CI, power, novelty effect, decision memo)
→ **Looker Studio** dashboard. The core story: validate data quality (duplicate users, group/page
mismatches) before trusting the result. The step-by-step plan lives in `guide.md` (local only, not committed).

## Setup
- macOS, Anaconda/Miniconda (conda at `/opt/miniconda3`)
- Conda env **`abtest`** (Python 3.11). Do not use venv. Activate with `conda activate abtest`.
  Packages: dbt-bigquery, google-cloud-bigquery, db-dtypes, pandas, statsmodels, scipy, matplotlib, jupyter.
  Recreate from `environment.yml`: `conda env create -f environment.yml`
- GitHub: https://github.com/DevarshiDave1120-cmd/ecommerce-ab-test-analysis (public), branch `main`
- Google Cloud project: `ab-test-portfolio` (BigQuery sandbox, location US). Project ID: `ab-test-portfolio-512322`
- dbt profile lives in `~/.dbt/profiles.yml` (outside the repo, oauth via gcloud ADC)

## Data quality findings
From `scripts/01_profile_raw.py` on `data/raw/ab_data.csv` (pre-cleaning):
- **294,478 rows**, **290,584 unique users**, no nulls. 3,894 users appear exactly twice (none more); 0 fully identical rows.
- group × landing_page:

  | group | old_page | new_page |
  |---|---|---|
  | control | 145,274 ✅ | 1,928 ❌ |
  | treatment | 1,965 ❌ | 145,311 ✅ |

  → **3,893 mismatched rows**.
- **Overlap:** every mismatched row belongs to a repeat user. 3,893 repeat users have one correct + one mismatched row;
  1 repeat user has two correct rows. 1,895 repeat users were recorded in **both** groups.
- Timestamps: all `YYYY-MM-DD HH:MM:SS.ffffff`, no time zone. Range **2017-01-02 13:42 → 2017-01-24 13:41**
  (22 days, 23 calendar dates; first and last dates are partial).
- Raw overall conversion: 35,237 / 294,478 = **11.97%**.

## Decisions
- **Main analysis excludes every user who appears more than once** (all 3,894, i.e. all 7,788 of their rows).
  Why: a repeat user may have seen both pages, so their outcome can't be cleanly attributed to one variant.
  Result: **286,690 users** (control 143,293, treatment 143,397), zero mismatches.
- **Sensitivity check** keeps repeat users' correct row instead: drop mismatched rows, then keep each user's
  first event. Result: **290,584 users** (control 145,274, treatment 145,310). Report whether the conclusion changes.
- dbt: `int_ab_users_clean` = main rule (marts build on this); `int_ab_users_sensitivity` = sensitivity rule.

## Rules
1. **Explain each command before running it**: what it does and why, in plain language.
2. **Never commit credentials or the raw CSV.** No service-account keys, `*.json` credentials,
   `.env` files, or anything in `data/raw/`. Check `git status` before every commit.
3. **Commit after each step** of the guide (e.g. 1b, 1c, 2, 3...) with a clear message.
