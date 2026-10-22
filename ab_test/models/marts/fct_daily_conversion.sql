-- One row per date per experiment group, from the main-analysis user table.
-- Feeds the daily time-series chart and the novelty-effect check (Step 6e).
-- Note: the first (2017-01-02) and last (2017-01-24) dates are partial days.
SELECT
  event_date,
  experiment_group,
  COUNT(*)                              AS users,  -- one row per user, so rows = users
  SUM(converted)                        AS conversions,
  SAFE_DIVIDE(SUM(converted), COUNT(*)) AS conversion_rate
FROM {{ ref('int_ab_users_clean') }}
GROUP BY 1, 2
