-- One row per experiment group for the whole test, from the main-analysis user table.
-- Feeds the dashboard scorecards and the z-test inputs (Step 6c).
SELECT
  experiment_group,
  COUNT(*)                              AS users,  -- one row per user, so rows = users
  SUM(converted)                        AS conversions,
  SAFE_DIVIDE(SUM(converted), COUNT(*)) AS conversion_rate,
  MIN(event_date)                       AS start_date,
  MAX(event_date)                       AS end_date
FROM {{ ref('int_ab_users_clean') }}
GROUP BY 1
