-- One row per raw event: rename columns, derive the event date, and flag
-- rows where the assigned group doesn't match the page shown.
-- No rows are removed here; cleaning happens in the intermediate layer.
SELECT
  user_id,
  timestamp       AS event_ts,    -- already TIMESTAMP via bq load --autodetect
  DATE(timestamp) AS event_date,
  `group`         AS experiment_group,
  landing_page,
  converted,
  CASE
    WHEN `group` = 'control'   AND landing_page = 'old_page' THEN FALSE
    WHEN `group` = 'treatment' AND landing_page = 'new_page' THEN FALSE
    ELSE TRUE
  END AS is_assignment_mismatch
FROM {{ source('raw', 'ab_data') }}
