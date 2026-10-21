-- Step 3: profile the raw table in BigQuery.
-- Expect four group x landing_page combinations (two are assignment errors),
-- and row_count > users where some users appear more than once.
-- `group` is a reserved word in BigQuery, so it needs backticks;
-- ROWS is reserved too, hence row_count.
SELECT
  `group`,
  landing_page,
  COUNT(*) AS row_count,
  COUNT(DISTINCT user_id) AS users,
  SUM(converted) AS conversions
FROM `ab-test-portfolio-512322.raw.ab_data`
GROUP BY 1, 2
ORDER BY 1, 2;
