-- Sensitivity check: keep repeat users, using their correctly assigned row.
-- Drop mismatched rows, then keep each user's first remaining event.
SELECT *
FROM {{ ref('stg_ab_events') }}
WHERE NOT is_assignment_mismatch
QUALIFY ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY event_ts) = 1
