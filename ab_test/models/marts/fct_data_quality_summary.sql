-- Data-quality funnel for the dashboard: one row per metric, in display order.
-- Same counts as the data-quality cell in notebook step 6a, plus the final user count
-- of each intermediate model. Checked against the expected counts by
-- tests/assert_data_quality_counts.sql.
WITH per_user AS (
  SELECT
    user_id,
    COUNT(*)                         AS n_rows,
    COUNTIF(is_assignment_mismatch)  AS n_mismatch
  FROM {{ ref('stg_ab_events') }}
  GROUP BY user_id
),

raw_counts AS (
  SELECT
    SUM(n_rows)                             AS raw_rows,
    COUNT(*)                                AS raw_users,
    SUM(n_mismatch)                         AS mismatched_rows,
    SUM(IF(n_rows = 1, n_mismatch, 0))      AS mismatched_rows_from_single_row_users,
    COUNTIF(n_rows > 1)                     AS repeat_users,
    COUNTIF(n_rows > 1 AND n_mismatch > 0)  AS repeat_users_with_mismatch
  FROM per_user
)

SELECT 1 AS step, 'Raw rows' AS metric, raw_rows AS value FROM raw_counts
UNION ALL SELECT 2, 'Raw unique users', raw_users FROM raw_counts
UNION ALL SELECT 3, 'Rows with group/page mismatch', mismatched_rows FROM raw_counts
UNION ALL SELECT 4, 'Mismatched rows from users appearing once', mismatched_rows_from_single_row_users FROM raw_counts
UNION ALL SELECT 5, 'Repeat users (removed from main analysis)', repeat_users FROM raw_counts
UNION ALL SELECT 6, 'Repeat users with a mismatched row', repeat_users_with_mismatch FROM raw_counts
UNION ALL SELECT 7, 'Final users: main analysis', (SELECT COUNT(*) FROM {{ ref('int_ab_users_clean') }})
UNION ALL SELECT 8, 'Final users: sensitivity check', (SELECT COUNT(*) FROM {{ ref('int_ab_users_sensitivity') }})
