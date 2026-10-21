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
- Google Cloud project: `ab-test-portfolio` (BigQuery sandbox, location US). Project ID: _TBD_
- dbt profile lives in `~/.dbt/profiles.yml` (outside the repo, oauth via gcloud ADC)

## Rules
1. **Explain each command before running it**: what it does and why, in plain language.
2. **Never commit credentials or the raw CSV.** No service-account keys, `*.json` credentials,
   `.env` files, or anything in `data/raw/`. Check `git status` before every commit.
3. **Commit after each step** of the guide (e.g. 1b, 1c, 2, 3...) with a clear message.
