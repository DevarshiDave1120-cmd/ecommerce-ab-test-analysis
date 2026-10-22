-- Main analysis: keep only users who appear exactly once in raw.
-- Users with 2+ rows may have seen both pages, so all of their rows are excluded.
-- The count is taken over ALL raw rows, before the mismatch filter, so a repeat user
-- can't sneak back in after their mismatched row is dropped.
WITH single_row_users AS (
  SELECT *
  FROM {{ ref('stg_ab_events') }}
  WHERE TRUE  -- BigQuery requires WHERE/GROUP BY/HAVING alongside QUALIFY
  QUALIFY COUNT(*) OVER (PARTITION BY user_id) = 1
)
SELECT *
FROM single_row_users
WHERE NOT is_assignment_mismatch  -- expected to remove 0 rows; kept as a safeguard
